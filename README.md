# opensearch-test-automation

Scripts for benchmarking and correctness testing OpenSearch engines (DataFusion vs Lucene).

Cloned onto EC2 instances by the CDK stack. Each script reads config from `~/.opensearch-env`.

## Structure

```
benchmark/
  run-benchmark.sh          # Runs OSB clickbench against a target host
  run-all.sh                # Orchestrates benchmark + correctness for both engines
correctness/
  run-correctness-test.sh   # Runs all 43 PPL queries, captures raw JSON responses
profiler/
  profile-opensearch.sh     # Captures 60s CPU flamegraph, uploads to S3
```

## Environment File

Each EC2 instance writes `~/.opensearch-env` at boot via user-data. Scripts source it for config:

```bash
# Example ~/.opensearch-env
ENGINE=datafusion                              # or "lucene"
S3_BUCKET=opensearch-codeguru-500923064869
DATAFUSION_HOST=172.31.85.56
LUCENE_HOST=172.31.81.86
WORKLOAD_PATH_DATAFUSION=/home/ec2-user/datafusion-workloads/clickbench
WORKLOAD_PATH_LUCENE=/home/ec2-user/lucene-workloads/clickbench
```

## Usage

```bash
# Run a single benchmark
bash benchmark/run-benchmark.sh --host 172.31.85.56 --engine datafusion --workload ~/datafusion-workloads/clickbench

# Run correctness test
bash correctness/run-correctness-test.sh 172.31.85.56 datafusion

# Run profiler manually
bash profiler/profile-opensearch.sh

# Run everything (auto-called by user-data on benchmark instance)
bash benchmark/run-all.sh
```
