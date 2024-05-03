#!/bin/bash
./get_plots_from_log.py --app-type hpa --response-log ../sample_logs/loop/hpa-hpa-response-time.csv \
    --resources-log ../sample_logs/loop/hpa-hpa-resource_usage.csv \
    --output-folder ../sample_results/loop/ --app-name hpa

./get_plots_from_log.py --app-type vpa --response-log ../sample_logs/loop/vpa-vpa-response-time.csv \
    --resources-log ../sample_logs/loop/vpa-vpa-resource_usage.csv \
    --output-folder ../sample_results/loop/ --app-name vpa

./get_plots_from_log.py --app-type single-pod --response-log ../sample_logs/loop/single-pod-single-pod-response-time.csv \
    --resources-log ../sample_logs/loop/single-pod-single-pod-resource_usage.csv \
    --output-folder ../sample_results/loop/ --app-name single-pod

./get_plots_from_log.py --app-type two-container --response-log ../sample_logs/loop/two-container-two-container-response-time.csv \
    --resources-log ../sample_logs/loop/two-container-two-container-resource_usage.csv \
    --output-folder ../sample_results/loop/ --app-name two-container

./get_plots_from_log.py --app-type two-pod-same-node --response-log ../sample_logs/loop/two-pod-same-node-two-pod-same-node-response-time.csv \
    --resources-log ../sample_logs/loop/two-pod-same-node-two-pod-same-node-resource_usage.csv \
    --output-folder ../sample_results/loop/ --app-name two-pod-same-node

./get_plots_from_log.py --app-type hpa --response-log ../sample_logs/lorem/hpa-hpa-response-time.csv \
    --resources-log ../sample_logs/lorem/hpa-hpa-resource_usage.csv \
    --output-folder ../sample_results/lorem/ --app-name hpa

./get_plots_from_log.py --app-type vpa --response-log ../sample_logs/lorem/vpa-vpa-response-time.csv \
    --resources-log ../sample_logs/lorem/vpa-vpa-resource_usage.csv \
    --output-folder ../sample_results/lorem/ --app-name vpa

./get_plots_from_log.py --app-type single-pod --response-log ../sample_logs/lorem/single-pod-single-pod-response-time.csv \
    --resources-log ../sample_logs/lorem/single-pod-single-pod-resource_usage.csv \
    --output-folder ../sample_results/lorem/ --app-name single-pod

./get_plots_from_log.py --app-type two-container --response-log ../sample_logs/lorem/two-container-two-container-response-time.csv \
    --resources-log ../sample_logs/lorem/two-container-two-container-resource_usage.csv \
    --output-folder ../sample_results/lorem/ --app-name two-container

./get_plots_from_log.py --app-type two-pod-same-node --response-log ../sample_logs/lorem/two-pod-same-node-two-pod-same-node-response-time.csv \
    --resources-log ../sample_logs/lorem/two-pod-same-node-two-pod-same-node-resource_usage.csv \
    --output-folder ../sample_results/lorem/ --app-name two-pod-same-node

./get_plots_from_log.py --app-type two-pod-diff-node --response-log ../sample_logs/loop/two-pod-diff-node-two-pod-diff-node-response-time.csv \
    --resources-log ../sample_logs/loop/two-pod-diff-node-two-pod-diff-node-resource_usage.csv \
    --output-folder ../sample_results/loop/ --app-name two-pod-diff-node

./get_plots_from_log.py --app-type two-pod-diff-node --response-log ../sample_logs/lorem/two-pod-diff-node-two-pod-diff-node-response-time.csv \
    --resources-log ../sample_logs/lorem/two-pod-diff-node-two-pod-diff-node-resource_usage.csv \
    --output-folder ../sample_results/lorem/ --app-name two-pod-diff-node

