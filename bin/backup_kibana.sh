#!/bin/bash
tar czf /redis/kibana_$(date +%F-%H_%M).tgz /elasticsearch/es-cn-prod/nodes/0/indices/.kibana
