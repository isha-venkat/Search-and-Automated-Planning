# Search-and-Automated-Planning
# 🧠 AI Search & Automated Planning Projects

This repository showcases two Artificial Intelligence projects developed as part of coursework focused on **Search Algorithms** and **Automated Planning**.

The work demonstrates how AI techniques can be applied to structured problems, including **Sudoku solving using Constraint Satisfaction (CSP)** and **autonomous mission planning using PDDL**.

---

## 📌 Overview

Artificial Intelligence enables systems to solve complex problems through structured reasoning and decision-making. This repository focuses on:

* Solving Sudoku using **CSP and heuristic search**
* Designing a **planning system for a lunar rover mission**
* Applying core AI concepts such as search, constraints, and state-space modeling

---

## 1️⃣ Sudoku Solver using Constraint Satisfaction (CSP)

An intelligent Sudoku solver implemented in Python using classical AI techniques.

### 🔍 Features

* Solves any valid 9×9 Sudoku puzzle
* Accepts input from `.txt` or `.csv` files
* Outputs a clean, readable solved grid
* Tracks performance metrics (time, steps, backtracking)
* Optional GUI using Tkinter

---

### 🧠 AI Techniques Used

* Backtracking Search
* Arc Consistency (AC-3)
* Forward Checking
* Heuristics:

  * Minimum Remaining Values (MRV)
  * Degree Heuristic
  * Least Constraining Value (LCV)

---

### ⚙️ Problem Formulation (CSP)

* **Variables:** Each cell in the 9×9 grid
* **Domain:** Values from 1 to 9
* **Constraints:**

  * Each row must contain unique values
  * Each column must contain unique values
  * Each 3×3 subgrid must contain unique values

This follows the formal definition of Sudoku as a constraint satisfaction problem described in the coursework .

---

### 📊 Performance Metrics

* Number of recursive calls
* Number of backtracks
* Execution time

---

### ▶️ How to Run

```bash
python sudoku_solver.py input.txt
```

---

## 2️⃣ Lunar Mission Automated Planning (PDDL)

A planning system for a robotic lunar mission modeled using **PDDL (Planning Domain Definition Language)**.

---

### 🚀 Scenario

A rover is deployed from a lander to autonomously:

* Navigate between waypoints
* Capture images
* Perform subsurface scans
* Collect soil and rock samples
* Return samples to the lander

All operations are fully autonomous due to the harsh lunar environment .

---

### 🧩 Domain Design

#### Objects:

* Rovers
* Landers
* Locations (waypoints)

#### Predicates:

* Rover position
* Connectivity between locations
* Data captured (image / scan)
* Sample collection status
* Rover–lander relationships

#### Actions:

* Deploy rover
* Move between locations
* Capture image
* Perform scan
* Collect sample
* Transmit data

Each action is defined using:

* Preconditions
* Effects that update the world state 

---

### 🎯 Missions Implemented

#### Mission 1

* Single rover deployment
* Image, scan, and sample collection

#### Mission 2

* Multi-rover scenario
* Multiple tasks and coordination

#### Mission 3 (Extension)

* Astronaut involvement
* Docking bay constraints
* Control room dependency for communication

---

### 🛠 Tools Used

* PDDL
* Planning.Domains editor
* Fast Downward / FF Planner

---

### ▶️ How to Run

1. Open: https://editor.planning.domains/
2. Upload domain and problem files
3. Run planner to generate solution plan

---

## 🧠 Key Concepts Learned

* Constraint Satisfaction Problems (CSP)
* Heuristic search optimization
* Backtracking vs brute-force comparison
* Automated planning with PDDL
* State-space representation
* Action modeling using predicates and effects

---

## ⚖️ Theoretical Analysis

The Sudoku solver was compared theoretically with an **A*** search approach, focusing on:

* Time complexity
* Search efficiency
* Exploration of the solution space

This comparison was required as part of the coursework .

---

## 🛠 Tech Stack

* Python
* Tkinter (GUI)
* PDDL
* Classical AI planning tools

---

## 📂 Repository Structure

```
.
├── sudoku-csp-solver/
│   ├── sudoku_solver.py
│   ├── puzzles/
│   └── gui/
│
├── lunar-mission-planner/
│   ├── domain.pddl
│   ├── mission1.pddl
│   ├── mission2.pddl
│   └── mission3.pddl
```

---

## 📈 Future Improvements

* Add visualization of solving steps
* Improve solver performance and optimization
* Introduce additional planning constraints (energy, time limits)
* Integrate planning with simulation environments

---

## 👨‍💻 Author

Computer Science undergraduate with a focus on **Artificial Intelligence, Machine Learning, and intelligent systems development**.

---

## ⭐ Why This Project Matters

This project demonstrates practical implementation of:

* AI search algorithms
* Constraint reasoning
* Autonomous decision-making systems

These concepts are foundational in:

* Robotics
* Optimization problems
* Game solving
* Real-world AI systems
