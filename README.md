# API Functional Testing Using JMeter — Educational Framework

> **🎓 For education purposes only.** This project is a learning resource and template that shows **how to use Apache JMeter for functional API testing** — not a production load/performance runner.

This repository demonstrates how to build a **functional API testing framework** using [Apache JMeter](https://jmeter.apache.org/). It walks through the core patterns you need for real-world API test automation:

- How to organize test cases in JMeter
- How to validate API responses (status codes **and** response bodies)
- How to run the same tests against multiple environments (`DEV`, `QA`, `PROD`)
- How to drive test data with JMeter variables
- How to package it all in Docker for portable / CI/CD execution

The included test plan (a sanity suite against the public [ReqRes](https://reqres.in/) API) is just an example. The point is the **framework and concepts** — you can apply them to test any REST API.

---

## What You Will Learn

| # | Concept | Where to see it in this repo |
| - | ------- | ---------------------------- |
| 1 | Structure a JMeter test plan for functional tests | `Master Controller` → `All_Test_Cases` |
| 2 | Group test cases by HTTP method | `GET_Calls`, `Post_Calls`, `PUT_Calls`, `Patch_Calls`, `Delete_Calls` |
| 3 | Validate status codes and response data | `Response Assertions` on every sampler |
| 4 | Make tests environment-aware | `If Controller` (DEV / QA / PROD) + `ParameterizedController` |
| 5 | Data-driven requests with variables | `base_url`, `api_version`, `name`, `job`, `${Environment}` |
| 6 | Reuse test logic from multiple places | `Module Controller` |
| 7 | Capture results per environment | `Result Collector` → `TestResults/` |
| 8 | Run tests headlessly (CI/CD friendly) | JMeter non-GUI mode |
| 9 | Containerize the framework | `Dockerfile` + `entrypoint.sh` |

---

## Features

- ✅ **Functional API testing** — validates real API behavior (correct response for a given request), not just load
- 🔁 **Environment-aware execution** — same test suite runs on `DEV`, `QA`, or `PROD` with per-environment data
- 🧪 **Full REST lifecycle coverage** — `GET`, `POST`, `PUT`, `PATCH`, `DELETE`
- 🔍 **Response assertions** — checks both response **codes** and response **body content**
- 🗂️ **Modular test organization** — test cases grouped by HTTP method, reusable via `Module Controller`
- 🐳 **Dockerized runner** — JMeter + Plugins Manager bundled in an image for one-command execution
- 📊 **Per-environment reports** — timestamped result files that persist outside the container
- 🔌 **Auto plugin installation** — `entrypoint.sh` installs any missing JMeter plugins at runtime

---

## Included Test Plan (Sanity Example)

| Test Case | Method | Endpoint        | Validations                                      |
| --------- | ------ | --------------- | ------------------------------------------------ |
| TC01      | GET    | `/api/users/2`  | Response code = `200`                            |
| TC02      | POST   | `/api/users`    | Response code = `201`, body contains `name`/`job` |
| TC03      | PUT    | `/api/users/2`  | Response code = `200`, body contains `name`/`job` |
| TC04      | PATCH  | `/api/users/2`  | Response code = `200`, body contains `name`/`job` |
| TC05      | DELETE | `/api/users/2`  | Response code = `204`                            |

> Use the same pattern to add **hundreds** of functional cases — checklists, authentication flows, error scenarios, boundary values — each grouped under its controller.

---

## Project Structure

```
.
├── New_Sanity_Test.jmx       # JMeter test plan — the framework/methodology example
├── Dockerfile                # Container image: OpenJDK 11 + JMeter 5.4.1 + plugins
├── entrypoint.sh             # Installs required plugins, then runs JMeter non-GUI
├── .gitattributes            # LF line-ending normalization
├── TestResults/              # Sample results from DEV / QA / PROD runs
│   ├── DEV_Sanity_<ts>.csv
│   ├── QA_Sanity_<ts>.csv
│   └── PROD_Sanity_<ts>.csv
└── README.md
```

---

## How the Test Plan Is Organized

The JMX file showcases a clean, reusable way to structure a functional API framework:

```
Test Plan: Sanity_Test - Test Plan
├── HTTP Header Manager            (Content-Type: application/json)
├── HTTP Cache Manager
├── HTTP Cookie Manager
├── User Defined Global Variables  (base_url, api_version, Environment, ...)
├── Master Controller (Thread Group)          ← the active runner
│   ├── If Controller › PROD        → ParameterizedController (name/job) → Module Controller
│   ├── If Controller › QA          → ParameterizedController (name/job) → Module Controller
│   ├── If Controller › DEV         → ParameterizedController (name/job) → Module Controller
│   └── Debug Sampler
├── All_Test_Cases (disabled Thread Group)    ← reusable test-case library
│   └── Test Cases (GenericController)
│       ├── GET_Calls      → TC01 (GET    + assertions + timer)
│       ├── Post_Calls     → TC02 (POST   + assertions + timer)
│       ├── PUT_Calls      → TC03 (PUT    + assertions + timer)
│       ├── Patch_Calls    → TC04 (PATCH  + assertions + timer)
│       └── Delete_Calls   → TC05 (DELETE + assertions + timer)
└── Result Collector       → TestResults/${Environment}_${Report}.csv
```

### How the environment switching works

1. Variables like `base_url` and `api_version` are defined once in **User Defined Global Variables**.
2. Each environment block uses an **If Controller** with a Groovy condition, e.g. `props.get("Environment") == "DEV"`.
3. The matching block runs a **ParameterizedController** that injects environment-specific test data.
4. A **Module Controller** then invokes the shared `All_Test_Cases` suite, so test logic is defined **once** and reused everywhere.

### Environment-Specific Test Data

| Environment | `name`  | `job`      |
| ----------- | ------- | ---------- |
| DEV         | Arvind  | Developer  |
| QA          | PAREK   | Qa         |
| PROD        | Anshu   | Devops     |

---

## Prerequisites

**Without Docker:**

- [Java 8+](https://www.oracle.com/java/technologies/downloads/) (`JAVA_HOME` set)
- [Apache JMeter 5.x](https://jmeter.apache.org/download_jmeter.cgi) (`JMETER_HOME/bin` on `PATH`)
- [JMeter Plugins Manager](https://jmeter-plugins.org/wiki/PluginsManager/) — required for the `ParameterizedController`

**With Docker:**

- [Docker](https://www.docker.com/products/docker-desktop/)

---

## Running the Framework

### 1. GUI Mode (best for learning)

```bash
jmeter -t New_Sanity_Test.jmx
```

Select the environment in **User Defined Variables - Set Env value_DEV,QA,PROD** (or pass it as a property), then hit **Start**. Watch requests and assertion results live in **View Results Tree** — this is how you inspect both the request and response for each functional case.

### 2. Non-GUI (CLI) Mode

Pick the environment with the `Environment` property — `DEV`, `QA`, or `PROD`:

```bash
jmeter -n -t New_Sanity_Test.jmx -JEnvironment=DEV
jmeter -n -t New_Sanity_Test.jmx -JEnvironment=QA
jmeter -n -t New_Sanity_Test.jmx -JEnvironment=PROD
```

Results are written automatically to:

```
TestResults/<Environment>_Sanity_<MM-dd-yyyy-HHmmss>.csv
```

### 3. Docker Mode

Build the image:

```bash
docker build -t jmeter-api-framework .
```

Run the tests:

```bash
docker run --rm \
  -e JMX_FILE=/opt/jmeter/New_Sanity_Test.jmx \
  -e RESULTS_FILE=/opt/jmeter/results/result.jtl \
  -v "$(pwd)":/opt/jmeter/results \
  jmeter-api-framework
```

`entrypoint.sh` will:

1. Detect and install any plugins required by the JMX file
2. Execute JMeter in non-GUI mode
3. Write the results file and generate an HTML dashboard under `/opt/jmeter/results/report`

> Mount a local directory to `/opt/jmeter/results` to persist the results and HTML report.

---

## Key Variables

| Variable        | Default              | Description                                      |
| --------------- | -------------------- | ------------------------------------------------ |
| `Environment`   | `DEV`                | Target environment: `DEV`, `QA`, or `PROD`        |
| `base_url`      | `reqres.in`          | Base domain of the API under test                |
| `api_version`   | `api`                | API version path segment                         |
| `timeDelay`     | `5000`               | Delay between iterations                         |
| `Base_Dir_Path` | (auto)               | Base directory used to resolve the results path  |
| `Report`        | `Sanity_<timestamp>` | Report name suffix                               |

---

## Using This to Build Your Own API Tests

1. **Point at your API** — change `base_url` and `api_version` in **User Defined Global Variables**.
2. **Add functional cases** — duplicate a sampler under the matching controller and adjust method, path, and request body.
3. **Add assertions** — assert the response code and the body fields your contract requires (e.g. match on `name`, IDs, error messages).
4. **Add an environment** — copy an existing `If Controller` block, change the condition and the `ParameterizedController` values.
5. **Add auth** — e.g. an `HTTP Header Manager` with a `Bearer` token, or a `JSR223`/BeanShell pre-processor for dynamic tokens.
6. **Run in CI** — use the non-GUI or Docker command and upload `TestResults/*` as build artifacts.

---

## Sample Results

The `TestResults/` folder contains committed sample executions for each environment:

| File                                 | Environment |
| ------------------------------------ | ----------- |
| `DEV_Sanity_02-19-2025-165804.csv`   | DEV         |
| `QA_Sanity_02-19-2025-165749.csv`    | QA          |
| `PROD_Sanity_02-19-2025-165731.csv`  | PROD        |

Each file captures full request/response detail (headers, assertions, timings) in JMeter's JTL format.

---

## License

This project is open source and available under the [MIT License](LICENSE).