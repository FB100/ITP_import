# `itp_import.sh` — Automated Artemis Exercise Importer for ITP

What this script does:

- Cloning the exercise, solution, and tests repositories  
- Cloning the corresponding old exercise repositories  
- Updating all Gradle wrappers to version `9.0.0`  
- Copying contents of the old exercises into the new exercise structure

---

## Usage

```bash
./itp_import.sh <git-url>
````

Example:

```bash
./itp_import.sh https://[TUM-Username]@artemis.tum.de/git/itp2526h07e02-exercise.git
```

### Required Argument

| Argument    | Description                                                                    |
| ----------- | ------------------------------------------------------------------ ------------|
| `<git-url>` | Any of the 6 Artemis Git URLs from the new or old exercise you want to import. |

---

## What the Script Does

### 2. Create Local Folder Structure

For an exercise like `h07e02`, it creates:

```
h07e02/
├── <exercise>-exercise/
├── <exercise>-solution/
├── <exercise>-tests/
└── old/
    ├── <exercise>old-exercise/
    ├── <exercise>old-solution/
    └── <exercise>old-tests/
```

---

### 3. Clone All Related Repositories

The script reconstructs the correct Artemis repository URLs and clones:

| Type     | Current Semester Repo | Old Semester Repo        |
| -------- | --------------------- | ------------------------ |
| Exercise | `<name>-exercise.git` | `<name>old-exercise.git` |
| Solution | `<name>-solution.git` | `<name>old-solution.git` |
| Tests    | `<name>-tests.git`    | `<name>old-tests.git`    |

---

### 4. Update Gradle Wrappers

For every repository (except those under `old/`), the script:

* Makes `gradlew` executable
* Runs:

```
./gradlew wrapper --gradle-version 9.0.0
```

This ensures all imported projects use the same Gradle version.

---

### 5. Copy Old Exercise Code into the New Structure

Using `rsync -a --delete`, the script copies:

| From (old)                      | To (new)              |
| ------------------------------- | --------------------- |
| `src/de/tum/cit/ase` (exercise) | `src/de/tum/cit/aet`  |
| `src/de/tum/cit/ase` (solution) | `src/de/tum/cit/aet`  |
| `test/de/tum/cit/ase` (tests)   | `test/de/tum/cit/aet` |

The target directory is fully replaced.

---

## Requirements

* bash
* git
* rsync
* grep with PCRE support (`grep -P`)
* Internet access to Artemis Git

---

## Error Conditions

The script will exit early if:

* The wrong number of arguments is given
* No valid exercise number (`hXXeYY`) is found
* A repository fails to clone
* The Gradle wrapper update fails

---
