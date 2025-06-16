# WSL Search GUI: A Simple GUI for Search Commands

This program provides a user-friendly graphical interface (GUI) to simplify the use of powerful search commands: `find`, `grep`, and `pdfgrep`. Instead of typing commands in the terminal, users can perform complex searches with just a few clicks.

## Key Features

- **Easy File Search:** Quickly locate files and directories using the `find` command.
- **Text Search:** Search for specific text patterns within files using `grep`.
- **PDF Content Search:** Find text inside PDF documents using `pdfgrep`.
- **No Terminal Needed:** Designed for users who prefer not to use the command line.
- **Integrated Workflow:** All search tools are accessible from a single interface.

## Requirements

- **WSL2 (Windows Subsystem for Linux 2):** The program runs Linux commands via WSL2. Make sure WSL2 is installed and set up on your system. Check the official documentation to install it:
    ```
    https://learn.microsoft.com/en-us/windows/wsl/install
    ```
- **pdfgrep:** Install `pdfgrep` in your chosen WSL2 Linux distribution (e.g., Ubuntu) using:
    ```
    sudo apt install pdfgrep
    ```

## How to Use

1. **Start the program:** Double-click or open `click_me.md` to launch the GUI.
2. **Select directory** write or paste the directory you want to search on using Windows format, for exaple: `C:\Users\JohnDoe\Desktop`. If left blank it will use the directory in which the script is running
3. **Choose search type:** Select whether you want to search for files, text, or PDF content.
4. **Select search options** Use the check boxes to customize your search
5. **View Results:** Results will be outputed in *search_results.txt*, this file will be opened at the end of the search.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please submit a pull request or open an issue on the project's repository.

## Acknowledgments

- Thanks to the developers of `find`, `grep`, and `pdfgrep` for creating powerful command-line tools.
- Special thanks to the WSL2 team for making Linux commands accessible on Windows.

## License

This project is open-source and available under the MIT License. See the LICENSE file for more details.# wsl-search-gui
WSL GUI to search plain text, text in pdf's and files
