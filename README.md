# API Automation Testing Using JMeter Framework

A data-driven **API automation testing framework** built with [Apache JMeter](https://jmeter.apache.org/) that runs **sanity tests** against REST APIs across multiple environments (`DEV`, `QA`, `PROD`). It ships with a portable **Docker** runner so the same test suite can be executed anywhere — locally, in CI/CD, or in a container.

This framework is a clean, reusable starting point for teams that want to standardize API regression/sanity testing with JMeter while keeping environment-specific data separate from test logic.

---

## Features

- 🔁 **Environment-aware test execution** (`DEV`, `QA`, `PROD`) — variables are set per environment using JMeter's `ParameterizedController`
- 🧪 **Covers the full REST lifecycle**: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`
- ✅ **Built-in validations** with `Response Assertions` — verifies response codes *and* response body content (name / job)
- 🐳 **Dockerized runner** — JMeter, Plugins Manager, and required plugins are installed automatically in the image
- 📁 **Automated report generation** — results are saved per environment with timestamped names
- 🔌 **Auto plugin installation** — entrypoint detects missing plugins for the JMX file and installs them at runtime

---

## Test Cases Covered

| Test Case | Method | Endpoint              | Validations                                                        |
| --------- | ------ | --------------------- | ------------------------------------------------------------------ |
| TC01      | GET    | `/api/users/2`        | Response code = `200`                                              |
| TC02      | POST   | `/api/users`          | Response code = `201`, body contains `name` and `job`              |
| TC03      | PUT    | `/api/users/2`        | Response code = `200`, body contains `name` and `job`              |
| TC04      | PATCH  | `/api/users/2`        | Response code = `200`, body contains `name` and `job`              |
| TC05      | DELETE | `/api/users/2`        | Response code = `204`                                              |

> The sample tests target the public [ReqRes](https://reqres.in/) API. Point `base_url` / `api_version` at any REST endpoint to test your own services.

---

## Project Structure

```
.
├── New_Sanity_Test.jmx       # JMeter test plan (sanity suite, env-aware)
├── Dockerfile                # JMeter + plugins + entrypoint image
├── entrypoint.sh             # Runtime plugin check + JMeter execution
├── .gitattributes            # LF line-ending normalization
├── TestResults/              # Sample results from DEV / QA / PROD runs
│   ├── DEV_Sanity_<ts>.csv
│   ├── QA_Sanity_<ts>.csv
│   └── PROD_Sanity_<ts>.csv
└── README.md
```

---

## Test Plan Overview

The JMX test plan (`New_Sanity_Test.jmx`) is organized as:

- **Master Controller** (Thread Group) — the active runner used from GUI or CLI
  - **If Controller (DEV / QA / PROD)** — activates the matching environment block
  - **ParameterizedController** — injects environment-specific variables (e.g. `name`, `job`)
  - **Module Controller** — invokes the shared `All_Test_Cases` suite
- **All_Test_Cases** (disabled Thread Group) — the reusable collection of test cases:
  - `GET_Calls` → TC01
  - `Post_Calls` → TC02
  - `PUT_Calls` → TC03
  - `Patch_Calls` → TC04
  - `Delete_Calls` → TC05
- **Result Collector** — writes the results to `TestResults/${Environment}_${Report}.csv`

### Environment-Specific Test Data

Environment test data is injected by each `If Controller` block:

| Environment | `name`   | `job`     |
| ----------- | -------- | --------- |
| DEV         | Arvind   | Developer |
| QA          | PAREK    | Qa        |
| PROD        | Anshu    | Devops    |

---

## Prerequisites

To run **without Docker**:

- [Java 8+](https://www.oracle.com/java/technologies/downloads/) (`JAVA_HOME` set)
- [Apache JMeter 5.x](https://jmeter.apache.org/download_jmeter.cgi) (`JMETER_HOME/bin` on `PATH`)
- [JMeter Plugins Manager](https://jmeter-plugins.org/wiki/PluginsManager/) (required for `ParameterizedController`)

To run **with Docker**:

- [Docker](https://www.docker.com/products/docker-desktop/)

---

## Running the Tests

### 1. GUI Mode (exploration)

```bash
jmeter -t New_Sanity_Test.jmx
```

Then select the environment in **User Defined Variables - Set Env value_DEV,QA,PROD** (or pass it as a property) and hit **Start**. Watch results live in **View Results Tree**.

### 2. Non-GUI (CLI) Mode

Set the target environment with the `Environment` property (`DEV`, `QA`, or `PROD`):

```bash
jmeter -n -t New_Sanity_Test.jmx -JEnvironment=DEV
jmeter -n -t New_Sanity_Test.jmx -JEnvironment=QA
jmeter -n -t New_Sanity_Test.jmx -JEnvironment=PROD
```

Results are automatically written to:

```
TestResults/<Environment>_Sanity_<MM-dd-yyyy-HHmmss>.csv
```

### 3. Docker Mode

Build the image:

```bash
docker build -t jmeter-api-framework .
```

Run the tests for an environment:

```bash
docker run --rm \
  -e JMX_FILE=/opt/jmeter/New_Sanity_Test.jmx \
  -e RESULTS_FILE=/opt/jmeter/results/result.jtl \
  -v "$(pwd)":/opt/jmeter/results \
  jmeter-api-framework
```

The `entrypoint.sh` will:

1. Detect and install any plugins required by the JMX file
2. Execute JMeter in non-GUI mode
3. Write the results file and generate an HTML dashboard report under `/opt/jmeter/results/report`

> Mount a local directory to `/opt/jmeter/results` to persist the JTL results and HTML dashboard.

---

## Key Variables

| Variable        | Default            | Description                                       |
| --------------- | ------------------ | ------------------------------------------------- |
| `Environment`   | `DEV`              | Target environment: `DEV`, `QA`, or `PROD`         |
| `base_url`      | `reqres.in`        | Base domain of the API under test                 |
| `api_version`   | `api`              | API version path segment                          |
| `timeDelay`     | `5000`             | Delay between iterations                          |
| `Base_Dir_Path` | (auto)             | Base directory used to resolve the results path   |
| `Report`        | `Sanity_<timestamp>` | Report name suffix                              |

---

## Sample Results

The `TestResults/` folder contains committed sample executions for each environment:

| File                                 | Environment |
| ------------------------------------ | ----------- |
| `DEV_Sanity_02-19-2025-165804.csv`   | DEV         |
| `QA_Sanity_02-19-2025-165749.csv`    | QA          |
| `PROD_Sanity_02-19-2025-165731.csv`  | PROD        |

Each file captures the full request/response detail (headers, assertions, timings) in JMeter's JTL format.

---

## Extending the Framework

- **Add a new endpoint**: duplicate a sampler inside the relevant `GenericController` (`GET_Calls`, `Post_Calls`, etc.), then attach `Response Assertions`.
- **Add a new environment**: add a new `If Controller` + `ParameterizedController` block in the *Master Controller* with the environment's variables.
- **Test a different API**: update `base_url` and `api_version` in the **User Defined Global Variables** node.

---

## License

This project is open source and available under the [MIT License](LICENSE).