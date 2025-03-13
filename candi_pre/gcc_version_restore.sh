#!/bin/bash

# Configuration
source_dir="/usr/bin"
target_dir="/usr/local/bin"
read -p "Select GCC version to uninstall (10 or 11): " VERSION
link_suffix="-"${VERSION}  # Original suffix removed during creation

# --- Part 1: Remove symbolic links ---
echo "=== Symbolic Link Cleanup ==="
removed_count=0

# Find and remove links pointing to *-11 files in source_dir
while IFS= read -r -d '' link; do
    target=$(readlink -f "$link")
    if [[ "$target" == "${source_dir}/"*"${link_suffix}" ]]; then
        sudo rm -v "$link"
        ((removed_count++))
    fi
done < <(find "$target_dir" -type l -print0)

echo "Removed ${removed_count} symbolic links"

# --- Part 2: OpenMPI Reinstallation ---
read -p "Do you want to reinstall OpenMPI? [y/N] " reinstall_choice
if [[ "$reinstall_choice" =~ [yY] ]]; then
    declare -A package_commands=(
        ["apt"]="sudo apt install --reinstall openmpi-bin"
        ["dnf"]="sudo dnf reinstall openmpi"
        ["yum"]="sudo yum reinstall openmpi"
        ["zypper"]="sudo zypper install --force openmpi"
        ["pacman"]="sudo pacman -S openmpi"
    )

    # Detect available package managers
    available_pms=()
    for pm in "${!package_commands[@]}"; do
        command -v "$pm" >/dev/null && available_pms+=("$pm")
    done

    # Interactive selection
    if [ ${#available_pms[@]} -gt 0 ]; then
        echo "Available package managers:"
        for i in "${!available_pms[@]}"; do
            echo "$((i+1)). ${available_pms[$i]}"
        done

        read -p "Select package manager (number): " pm_num
        if [[ $pm_num =~ ^[0-9]+$ && $pm_num -le ${#available_pms[@]} ]]; then
            pm="${available_pms[$((pm_num-1))]}"
            echo "Executing: ${package_commands[$pm]}"
            eval "${package_commands[$pm]}"
        else
            echo "Invalid selection, skipping reinstallation."
        fi
    else
        echo "No supported package manager found."
    fi
fi

# --- Part 3: Verification ---
echo ""
echo "=== System Status ==="
echo "Removed links in ${target_dir}:"
find "$target_dir" -type l -ls | awk '{print $11 " -> " $13}'

echo ""
echo "=== OpenMPI Status ==="
if command -v mpirun &> /dev/null; then
    mpirun --version | head -n1
else
    echo "OpenMPI not detected in PATH"
fi
echo ""

echo "=== Compiler Versions ==="
compilers=("gcc" "g++" "gfortran")
for compiler in "${compilers[@]}"; do
    if command -v "$compiler" &> /dev/null; then
        echo -n "$compiler: (GCC) "
        $compiler --version | head -n1 | sed 's/.*) //'
    else
        echo "$compiler: Not found"
    fi
done

echo ""
echo "=== MPI Compiler Versions ==="
mpi_compilers=("mpicc" "mpicxx" "mpif90" "mpif77")
for mpi_comp in "${mpi_compilers[@]}"; do
    if command -v "$mpi_comp" &> /dev/null; then
        echo -n "$mpi_comp: (GCC) "
        $mpi_comp --version | head -n1 | sed 's/.*) //'
    else
        echo "$mpi_comp: Not installed"
    fi
done

echo ""
echo "Operation completed successfully."
