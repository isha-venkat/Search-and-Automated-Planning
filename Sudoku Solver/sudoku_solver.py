#!/usr/bin/env python3
"""
sudoku_solver.py

Sudoku solver using CSP techniques:
 - Initial arc-consistency (AC-3)
 - Backtracking search
 - MRV, Degree, LCV heuristics
 - Forward checking and AC-3 pruning
Now with user-friendly file selection (no CLI args required)
"""

import time  # For measuring solving time
import copy  # For deep copying data structures
import sys   # For system-specific parameters and functions
import os    # For file handling
import tkinter as tk  # GUI toolkit for Python
from tkinter import filedialog, messagebox  # File dialog and message boxes
from typing import List, Tuple, Dict, Set  # Type hints
from collections import deque  # Double-ended queue (used in AC-3)
from typing import List, Tuple, Dict, Set  # Duplicate import, safe to leave

# ---------------------------
# Utility / Parsing
# ---------------------------

def parse_puzzle_file(path: str) -> List[List[int]]:
    """Parse a 9x9 sudoku from a .txt or .csv file."""
    with open(path, 'r', encoding='utf-8') as f:  # Open file with UTF-8 encoding
        lines = [line.strip() for line in f if line.strip()]  # Strip whitespace and skip empty lines
    if len(lines) != 9:  # Ensure file has exactly 9 lines
        raise ValueError(f"Puzzle file must have 9 lines (found {len(lines)})")
    board = []  # Initialize the board
    for line in lines:  # Process each line
        if ',' in line:  # CSV format
            parts = [x.strip() for x in line.split(',')]
        else:  # Space-separated or continuous digits
            parts = list(line.replace(' ', ''))
        if len(parts) != 9:  # Ensure 9 values per line
            raise ValueError("Each line must contain 9 numbers or blanks")
        row = []  # Initialize row
        for p in parts:  # Process each cell
            if p in ['.', '0', '']:  # Empty cell indicators
                row.append(0)
            else:
                try:  # Convert valid digit to int
                    v = int(p)
                    if 1 <= v <= 9:
                        row.append(v)
                    else:
                        raise ValueError()
                except:  # Catch invalid entries
                    raise ValueError(f"Invalid entry '{p}' in puzzle")
        board.append(row)  # Add row to board
    return board  # Return the completed board

def print_board(board: List[List[int]]):
    """Print Sudoku board to console."""
    sep = "+-------+-------+-------+"  # Row separator
    for i in range(9):
        if i % 3 == 0:  # Print separator every 3 rows
            print(sep)
        row = board[i]  # Current row
        row_str = "| "  # Start row string
        for j, v in enumerate(row):  # Iterate through columns
            ch = str(v) if v != 0 else '.'  # Show '.' for empty cells
            row_str += ch + " "  # Add value to string
            if (j + 1) % 3 == 0:  # Add block separator every 3 columns
                row_str += "| "
        print(row_str)  # Print row
    print(sep)  # Print bottom separator

# ---------------------------
# CSP Setup
# ---------------------------

Cell = Tuple[int, int]  # Type alias for a cell
DIGITS = set(range(1, 10))  # Valid Sudoku digits

def all_cells():
    """Return a list of all 81 cells in the grid."""
    return [(r, c) for r in range(9) for c in range(9)]

def row_cells(r): return [(r, c) for c in range(9)]  # Cells in row r
def col_cells(c): return [(r, c) for r in range(9)]  # Cells in column c

def block_cells(r, c):
    """Return all cells in the 3x3 block containing cell (r, c)."""
    br, bc = (r // 3) * 3, (c // 3) * 3  # Top-left corner of block
    return [(br + dr, bc + dc) for dr in range(3) for dc in range(3)]

def neighbors_map():
    """Create a dictionary mapping each cell to its neighbors (row, col, block)."""
    neighbors = {}
    for r in range(9):
        for c in range(9):
            s = set(row_cells(r) + col_cells(c) + block_cells(r, c))
            s.discard((r, c))  # Remove the cell itself
            neighbors[(r, c)] = s
    return neighbors

NEIGHBORS = neighbors_map()  # Precompute neighbors

# ---------------------------
# AC-3
# ---------------------------

def revise(domains, xi, xj):
    """Revise domains[xi] to satisfy constraint with xj."""
    revised = False
    to_remove = set()
    for val in domains[xi]:  # Check each value in xi's domain
        if len(domains[xj]) == 1 and val in domains[xj]:  # If conflict with singleton
            to_remove.add(val)
    if to_remove:  # Remove conflicting values
        domains[xi] -= to_remove
        revised = True
    return revised

def ac3(domains):
    """AC-3 algorithm to enforce arc consistency."""
    queue = [(xi, xj) for xi in domains for xj in NEIGHBORS[xi]]  # Initialize queue
    while queue:
        xi, xj = queue.pop(0)  # Dequeue
        if revise(domains, xi, xj):  # Revise domains
            if len(domains[xi]) == 0:  # Empty domain, failure
                return False
            for xk in NEIGHBORS[xi]:  # Add neighbors to queue
                if xk != xj:
                    queue.append((xk, xi))
    return True  # Success

# ---------------------------
# Backtracking + Heuristics
# ---------------------------

class Metrics:
    """Keep track of solver statistics."""
    def __init__(self):
        self.assignments = 0
        self.backtracks = 0
        self.recursive_calls = 0

def select_unassigned_variable(domains, assignment):
    """MRV + Degree heuristic for selecting next variable."""
    unassigned = [(len(domains[v]), v) for v in domains if v not in assignment]  # List of unassigned cells
    mrv = min(unassigned, key=lambda x: x[0])[0]  # Minimum remaining values
    candidates = [v for s, v in unassigned if s == mrv]  # Cells with fewest options
    if len(candidates) == 1:  # Only one candidate
        return candidates[0]
    # Use Degree heuristic if tie: choose variable with most unassigned neighbors
    return max(candidates, key=lambda v: len([n for n in NEIGHBORS[v] if n not in assignment]))

def order_domain_values(var, domains):
    """LCV heuristic: order domain values to minimize conflicts with neighbors."""
    return sorted(domains[var], key=lambda val: sum(val in domains[n] for n in NEIGHBORS[var]))

def forward_check(domains, var, value, assignment):
    """Forward checking: remove value from neighbors' domains."""
    new_domains = {v: set(domains[v]) for v in domains}  # Copy domains
    new_domains[var] = {value}  # Assign value
    for n in NEIGHBORS[var]:
        if n not in assignment and value in new_domains[n]:
            new_domains[n].remove(value)  # Remove from neighbor
            if len(new_domains[n]) == 0:  # Failure
                return None
    return new_domains  # Return updated domains

def backtrack(domains, assignment, metrics):
    """Recursive backtracking solver with heuristics."""
    metrics.recursive_calls += 1  # Count recursion
    if len(assignment) == 81:  # All cells assigned
        return True, assignment

    var = select_unassigned_variable(domains, assignment)  # Choose next cell
    for val in order_domain_values(var, domains):  # Try values
        consistent = all(assignment.get(n) != val for n in NEIGHBORS[var] if n in assignment)
        if not consistent:
            continue  # Skip invalid values
        new_domains = forward_check(domains, var, val, assignment)  # Forward check
        if not new_domains:
            continue
        if not ac3(new_domains):  # Enforce arc consistency
            continue
        assignment[var] = val  # Tentatively assign
        metrics.assignments += 1
        success, result = backtrack(new_domains, assignment, metrics)  # Recurse
        if success:
            return True, result  # Solution found
        del assignment[var]  # Backtrack
        metrics.backtracks += 1
    return False, assignment  # No solution

# ---------------------------
# Solver Wrapper
# ---------------------------

def setup_domains(board):
    """Initialize domains for all cells from board."""
    domains = {}
    for r in range(9):
        for c in range(9):
            v = board[r][c]
            domains[(r, c)] = {v} if v != 0 else set(DIGITS)  # Singleton or all digits
    return domains

def initialize(domains):
    """Propagate initial constraints and run AC-3."""
    for var, dom in list(domains.items()):
        if len(dom) == 1:  # Pre-assigned cells
            val = next(iter(dom))
            for n in NEIGHBORS[var]:
                if val in domains[n] and len(domains[n]) > 1:
                    domains[n].discard(val)
                    if not domains[n]:  # Failure
                        return False
    return ac3(domains)  # Enforce arc consistency

def domains_to_board(domains):
    """Convert domain dictionary to 9x9 board."""
    board = [[0]*9 for _ in range(9)]
    for (r, c), dom in domains.items():
        if len(dom) == 1:
            board[r][c] = next(iter(dom))
    return board

def solve_sudoku(board):
    """Main solver wrapper."""
    metrics = Metrics()  # Track stats
    domains = setup_domains(board)  # Initialize domains
    if not initialize(domains):  # Run AC-3
        return False, board, metrics
    assignment = {v: next(iter(d)) for v, d in domains.items() if len(d) == 1}  # Current assignment
    success, final = backtrack(domains, assignment, metrics)  # Solve
    return success, domains_to_board(domains if not success else {v:{final[v]} for v in final}), metrics

# ---------------------------
# GUI
# ---------------------------

def launch_gui():
    """Sets up and runs the entire Tkinter GUI."""
    root = tk.Tk()
    root.title("Sudoku Solver (CSP + AC-3)")  # Window title
    root.resizable(False, False)  # Fixed window size

    # --- State variables ---
    state = {
        "board": [[0] * 9 for _ in range(9)],  # Current board
        "original_empty_cells": [[True] * 9 for _ in range(9)]  # Tracks initially empty cells
    }
    entry_grid: List[List[tk.Entry]] = []  # Grid of Tkinter Entry widgets

    # --- GUI Helper Functions ---
    def log(message: str):
        """Append message to log panel."""
        log_text.config(state="normal")
        log_text.insert(tk.END, f"{message}\n")
        log_text.see(tk.END)
        log_text.config(state="disabled")

    def display_board(board_to_display: List[List[int]], editable: bool):
        """Update GUI grid with board values."""
        original_empty = state["original_empty_cells"]
        for i in range(9):
            for j in range(9):
                entry = entry_grid[i][j]
                val = board_to_display[i][j]
                text = str(val) if val != 0 else ""

                entry.config(state="normal")
                entry.delete(0, tk.END)
                entry.insert(0, text)

                is_original_empty = original_empty[i][j]
                bg_color = "#d0f0d0" if is_original_empty and not editable else "white"
                fg_color = "#006400" if is_original_empty and not editable else "black"

                entry.config(disabledbackground=bg_color, disabledforeground=fg_color, fg=fg_color)
                entry.config(state="normal" if editable else "disabled")

    def get_board_from_gui() -> List[List[int]]:
        """Read current values from GUI grid into board."""
        new_board = []
        for i in range(9):
            row = []
            for j in range(9):
                val_str = entry_grid[i][j].get().strip()
                row.append(int(val_str) if val_str.isdigit() and 1 <= int(val_str) <= 9 else 0)
            new_board.append(row)
        return new_board

    def clear_board():
        """Reset GUI board to empty."""
        state["board"] = [[0] * 9 for _ in range(9)]
        state["original_empty_cells"] = [[True] * 9 for _ in range(9)]
        display_board(state["board"], editable=True)
        log("Board cleared. Ready for manual input.")

    def load_from_file():
        """Load a puzzle from a file into the GUI."""
        path = filedialog.askopenfilename(
            title="Select Sudoku Puzzle File",
            filetypes=[("Text/CSV Files", "*.txt *.csv"), ("All files", "*.*")]
        )
        if not path: return

        try:
            with open(path, 'r', encoding='utf-8') as f:
                lines = [line.strip() for line in f if line.strip()]
            if len(lines) != 9: raise ValueError("File must contain 9 lines.")

            loaded_board = []
            for line in lines:
                parts = [p.strip() for p in line.split(',')] if ',' in line else list(line.replace(' ', ''))
                if len(parts) != 9: raise ValueError("Each line must contain 9 values.")
                loaded_board.append([int(p) if p.isdigit() and 1 <= int(p) <= 9 else 0 for p in parts])

            state["board"] = loaded_board
            state["original_empty_cells"] = [[val == 0 for val in row] for row in state["board"]]
            display_board(state["board"], editable=True)
            log(f"Loaded puzzle from: {os.path.basename(path)}")
        except Exception as e:
            messagebox.showerror("File Error", f"Failed to parse file: {e}")
            log(f"Error loading file: {e}")

    def solve_and_display():
        """Solve current puzzle and update GUI."""
        current_board = get_board_from_gui()
        state["board"] = current_board
        state["original_empty_cells"] = [[val == 0 for val in row] for row in current_board]

        log("Solving puzzle...")
        root.update_idletasks()  # Refresh GUI

        start_time = time.time()
        success, solved_board, metrics = solve_sudoku(current_board)  # Solve
        elapsed = time.time() - start_time

        if success:  # Solution found
            state["board"] = solved_board
            display_board(solved_board, editable=False)
            print_board(solved_board)  # Print solved Sudoku to terminal
            log_msg = f" Solved in {elapsed:.4f}s. \n Assignments: {metrics.assignments}\n Backtracks: {metrics.backtracks}\n Recursive Calls: {metrics.recursive_calls}"
            log(log_msg)
            messagebox.showinfo("Success!", log_msg)
        else:  # No solution
            log_msg = f"No solution found after {elapsed:.4f}s."
            log(log_msg)
            messagebox.showerror("Failed", log_msg)

    # --- Widget Setup ---
    grid_frame = tk.Frame(root, bg="black", bd=2)
    grid_frame.pack(padx=10, pady=10)

    for i in range(9):  # Create 9x9 Entry widgets
        row_entries = []
        for j in range(9):
            pad_y = (2 if i % 3 == 0 else 1, 2 if i == 8 else 0)  # Padding for block borders
            pad_x = (2 if j % 3 == 0 else 1, 2 if j == 8 else 0)
            entry = tk.Entry(grid_frame, width=2, font=("Courier", 24, "bold"), justify="center", relief="flat", disabledbackground="white", disabledforeground="black")
            entry.grid(row=i, column=j, padx=pad_x, pady=pad_y)
            row_entries.append(entry)
        entry_grid.append(row_entries)

    btn_frame = tk.Frame(root)  # Frame for buttons
    btn_frame.pack(pady=(0, 10), fill="x", padx=10)
    tk.Button(btn_frame, text="Load File", command=load_from_file).pack(side=tk.LEFT, expand=True, fill="x", padx=2)
    tk.Button(btn_frame, text="Clear", command=clear_board).pack(side=tk.LEFT, expand=True, fill="x", padx=2)
    tk.Button(btn_frame, text="Solve", command=solve_and_display, bg="#4CAF50", fg="white", font=("Helvetica", 10, "bold")).pack(side=tk.LEFT, expand=True, fill="x", padx=2)

    log_frame = tk.Frame(root)  # Frame for log panel
    log_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=(0, 10))
    log_text = tk.Text(log_frame, height=6, state="disabled", font=("Courier", 10), bg="#f0f0f0", wrap="word")
    log_text.pack(fill=tk.BOTH, expand=True)

    # --- Initial State ---
    log("GUI ready. Load a puzzle or enter one manually.")
    clear_board()  # Clear board at start
    root.mainloop()  # Run the GUI event loop

# ---------------------------
# Main
# ---------------------------

if __name__ == "__main__":
    print("=== Sudoku Solver (CSP with Backtracking & AC-3) ===")
    choice = input("Do you want to use GUI or Console mode? (g/c): ").strip().lower()
   
    if choice == "c":
        # Console mode
        file_path = input("Enter the puzzle file name (e.g., puzzle_easy.txt, puzzle_medium.txt:").strip()
        
        # Check if file exists before proceeding
        if not os.path.exists(file_path):
            print(f" Error: The file '{file_path}' does not exist. Please check the name and try again.")
            sys.exit(1)  # Exit the program safely

        try:
            board = parse_puzzle_file(file_path)
            print("\n--- Initial Puzzle ---")
            print_board(board)
            start_time = time.time()
            success, solved_board, metrics = solve_sudoku(board)
            elapsed = time.time() - start_time

            if success:
                print("\n Solved Sudoku:")
                print_board(solved_board)
                print(f"Solved in {elapsed:.4f}s")
                print(f"Assignments: {metrics.assignments}, Backtracks: {metrics.backtracks}, Recursive Calls: {metrics.recursive_calls}")
            else:
                print(f"\nNo solution found after {elapsed:.4f}s.")
        except Exception as e:
            print(f"Error: {e}")

    elif choice == "g":
        print("Launching Sudoku GUI...")
        launch_gui()

    else:
        print("Invalid choice. Please enter 'g' for GUI or 'c' for Console.")

