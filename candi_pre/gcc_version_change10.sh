#!/bin/bash

# start or not?
read -p "Have you successfully installed gcc-10? [y/N]" if_installed
if [[ "$if_installed" =~ [yY] ]]; then
    echo ""
else
    echo "Please install gcc-10 before you executing this script!"
    exit
fi
read -p "Do you want to change the version(through creating symbolic links) of GCC to 10? [y/N] " change_choice
if [[ "$change_choice" =~ [yY] ]]; then
    source_dir="/usr/bin"
    target_dir="/usr/local/bin"

# --- Part 1: Create symbolic links ---

    sudo mkdir -p "$target_dir"

    echo "Creating symbolic links..."
    sudo find "$source_dir" -maxdepth 1 -type f -name '*-10' -print0 | while IFS= read -r -d '' file; do
        original_file="$file"
        link_name=$(basename "$original_file" | sed 's/-10$//')
        sudo ln -sf "$original_file" "$target_dir/$link_name"
        echo "Created link: $target_dir/$link_name → $original_file"
    done
fi

# --- Part 2: Interactive OpenMPI reinstallation ---
read -p "Do you want to reinstall OpenMPI? [y/N] " reinstall_choice
if [[ "$reinstall_choice" =~ [yY] ]]; then
    # Supported package managers
    declare -A package_managers=(
        ["apt"]="sudo apt install --reinstall openmpi-bin"
        ["dnf"]="sudo dnf reinstall openmpi"
        ["yum"]="sudo yum reinstall openmpi"
        ["zypper"]="sudo zypper install --force openmpi"
        ["pacman"]="sudo pacman -S openmpi"
    )

    # Detect available package managers
    available_pms=()
    for pm in "${!package_managers[@]}"; do
        if command -v "$pm" &> /dev/null; then
            available_pms+=("$pm")
        fi
    done

    # Package manager selection
    if [ ${#available_pms[@]} -gt 0 ]; then
        echo "Detected package managers:"
        for i in "${!available_pms[@]}"; do
            echo "$((i+1)). ${available_pms[$i]}"
        done

        read -p "Select package manager (enter number): " pm_num
        if [[ $pm_num =~ ^[0-9]+$ ]] && [ $pm_num -ge 1 ] && [ $pm_num -le ${#available_pms[@]} ]; then
            selected_pm="${available_pms[$((pm_num-1))]}"
            echo "Executing: ${package_managers[$selected_pm]}"
            eval "${package_managers[$selected_pm]}"
        else
            echo "Invalid selection, skipping reinstallation."
        fi
    else
        echo "No supported package manager found."
    fi
fi

# --- Part 3: Version information ---
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
