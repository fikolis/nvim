-- Level definitions for:
--   1. learning/k8s/learn_k8s.yaml       (25 Kubernetes & OpenShift levels — yaml.kubernetes + yamlls K8s schema)
--   2. learning/ansible/learn_ansible.yaml (25 Ansible & RHEL 9 levels — yaml.ansible + ansiblels)

local M = {}

local function make_helpers(H)
    local function yaml_list_slot(text, header_pat, idx, needle)
        local items = {}
        local inside = false
        for line in text:gmatch("[^\n]+") do
            if not inside and line:match(header_pat) then
                inside = true
            elseif inside then
                local val = line:match('^%s*%-%s*"(.-)"')
                if val then
                    items[#items + 1] = val
                elseif line:match("%S") and not line:match("^%s*#") then
                    break
                end
            end
        end
        return items[idx] == needle
    end

    local function yaml_first_child(text, parent_pat, child_pat)
        local inside = false
        for line in text:gmatch("[^\n]+") do
            if not inside and line:match(parent_pat) then
                inside = true
            elseif inside then
                if line:match("%S") and not line:match("^%s*#") then
                    return line:match(child_pat) ~= nil
                end
            end
        end
        return false
    end

    return H.play, H.oneline, H.ordered_lines, H.count_plain, H.code, yaml_list_slot, yaml_first_child
end

function M.k8s(H)
    local play, oneline, ordered_lines, count_plain, code, yaml_list_slot, yaml_first_child = make_helpers(H)

    return {
        {
            id = 1,
            title = "Deployment Scale & Image",
            goals = {
                code("replicas: 3", function(lines)
                    return oneline(play(lines, 1), "^%s*replicas:%s*3%s*$")
                end, 1, "^%s*replicas:"),
                code("nginx:1.27", function(lines)
                    return oneline(play(lines, 1), 'image:%s*"?nginx:1%.27"?%s*$')
                end, 2, "^%s*image:"),
                code("IfNotPresent", function(lines)
                    return oneline(play(lines, 1), "^%s*imagePullPolicy:%s*IfNotPresent%s*$")
                end, 3, "^%s*imagePullPolicy:"),
            },
        },
        {
            id = 2,
            title = "ConfigMap Env Paste",
            goals = {
                code("APP_ENV", function(lines)
                    return oneline(play(lines, 2), 'APP_ENV:%s*"production"%s*$')
                end, nil, "^%s*APP_ENV:"),
                code("LOG_ENV", function(lines)
                    return oneline(play(lines, 2), 'LOG_ENV:%s*"production"%s*$')
                end, nil, "^%s*LOG_ENV:"),
                code("METRICS_ENV", function(lines)
                    return oneline(play(lines, 2), 'METRICS_ENV:%s*"production"%s*$')
                end, nil, "^%s*METRICS_ENV:"),
            },
        },
        {
            id = 3,
            title = "Ports & ReadinessProbe",
            goals = {
                code("port 9999 off", function(lines)
                    return oneline(play(lines, 3), "^%s*#+%s*%-%s*containerPort:%s*9999")
                end, 1, "containerPort:%s*9999"),
                code("readinessProbe", function(lines)
                    return oneline(play(lines, 3), "^%s*readinessProbe:%s*$")
                end, 2, "readinessProbe:"),
                code("httpGet", function(lines)
                    return oneline(play(lines, 3), "^%s*httpGet:%s*$")
                end, 2, "httpGet:"),
                code("path: /healthz", function(lines)
                    return oneline(play(lines, 3), "^%s*path:%s*/healthz%s*$")
                end, 2, "path:%s*/healthz"),
            },
        },
        {
            id = 4,
            title = "InitContainer Args Redosled",
            goals = {
                code("1.", function(lines)
                    return yaml_list_slot(play(lines, 4), "^%s*args:%s*$", 1, "1. wait-for-db")
                end, nil, '"1%. wait%-for%-db"'),
                code("2.", function(lines)
                    return yaml_list_slot(play(lines, 4), "^%s*args:%s*$", 2, "2. run-migrations")
                end, nil, '"2%. run%-migrations"'),
                code("3.", function(lines)
                    return yaml_list_slot(play(lines, 4), "^%s*args:%s*$", 3, "3. seed-cache")
                end, nil, '"3%. seed%-cache"'),
                code("4.", function(lines)
                    return yaml_list_slot(play(lines, 4), "^%s*args:%s*$", 4, "4. warm-up")
                end, nil, '"4%. warm%-up"'),
            },
        },
        {
            id = 5,
            title = "Service Namespace Zamena",
            goals = {
                code("namespace", function(lines)
                    return oneline(play(lines, 5), "^%s*namespace:%s*prod_payments%s*$")
                end, nil, "^%s*namespace:"),
                code("owner-ns", function(lines)
                    return oneline(play(lines, 5), "^%s*owner%-ns:%s*prod_payments%s*$")
                end, nil, "^%s*owner%-ns:"),
                code("externalName", function(lines)
                    return oneline(play(lines, 5), "db%.prod_payments%.svc%.cluster%.local")
                end, nil, "^%s*externalName:"),
                code("selector ns", function(lines)
                    local text = play(lines, 5)
                    return oneline(text, "^%s*ns:%s*prod_payments%s*$") and not text:find("legacy_ns_05", 1, true)
                end, nil, "^%s*ns:"),
            },
        },
        {
            id = 6,
            title = "ConfigMap Surround",
            goals = {
                code('"eu_central"', function(lines)
                    return oneline(play(lines, 6), 'REGION:%s*"eu_central"%s*$')
                end, 1, "^%s*REGION:"),
                code('"8080"', function(lines)
                    return oneline(play(lines, 6), 'PORT:%s*"8080"%s*$')
                end, 2, "^%s*PORT:"),
                code('"30s"', function(lines)
                    return oneline(play(lines, 6), 'TIMEOUT:%s*"30s"%s*$')
                end, 3, "^%s*TIMEOUT:"),
            },
        },
        {
            id = 7,
            title = "Resources Void Delete",
            goals = {
                code("obrisi ephemeral", function(lines)
                    local text = play(lines, 7)
                    return not text:find("ephemeral-storage", 1, true) and not text:find("OBRISI_ME", 1, true)
                end, 2, "ephemeral%-storage:"),
                code('limits "512Mi"', function(lines)
                    local text = play(lines, 7)
                    return not text:find("FIXME", 1, true) and count_plain(text, '"512Mi"') >= 2
                end, 3, 'memory:%s*"FIXME"'),
            },
        },
        {
            id = 8,
            title = "YAML Indent Popravka",
            goals = {
                code("requests (4 sp)", function(lines)
                    return oneline(play(lines, 8), "^    requests:%s*$")
                end, 1, "requests:"),
                code("cpu (6 sp)", function(lines)
                    return oneline(play(lines, 8), '^      cpu:%s*"250m"%s*$')
                end, 2, "cpu:"),
                code("memory (6 sp)", function(lines)
                    return oneline(play(lines, 8), '^      memory:%s*"256Mi"%s*$')
                end, 2, "memory:"),
            },
        },
        {
            id = 9,
            title = "SecurityContext Hardening",
            goals = {
                code("runAsNonRoot", function(lines)
                    return oneline(play(lines, 9), "^%s*runAsNonRoot:%s*true%s*$")
                end, 1, "runAsNonRoot:"),
                code("readOnlyRootFS", function(lines)
                    return oneline(play(lines, 9), "^%s*readOnlyRootFilesystem:%s*true%s*$")
                end, 2, "readOnlyRootFilesystem:"),
                code("noPrivEsc", function(lines)
                    return oneline(play(lines, 9), "^%s*allowPrivilegeEscalation:%s*false%s*$")
                end, 3, "allowPrivilegeEscalation:"),
                code("privileged off", function(lines)
                    return oneline(play(lines, 9), "^%s*#+%s*privileged:%s*true")
                end, 4, "privileged:"),
            },
        },
        {
            id = 10,
            title = "HPA & Annotations",
            goals = {
                code("host", function(lines)
                    return oneline(play(lines, 10), 'host:%s*"api%.prod%.internal"%s*$')
                end, 1, "^%s*host:"),
                code("minReplicas: 2", function(lines)
                    return oneline(play(lines, 10), "^%s*minReplicas:%s*2%s*$")
                end, 2, "^%s*minReplicas:"),
                code("maxReplicas: 10", function(lines)
                    return oneline(play(lines, 10), "^%s*maxReplicas:%s*10%s*$")
                end, 2, "^%s*maxReplicas:"),
                code("beta_debug off", function(lines)
                    return oneline(play(lines, 10), '^%s*#+%s*beta_debug:%s*"true"')
                end, 3, "beta_debug:"),
            },
        },
        {
            id = 11,
            title = "NetworkPolicy Lockdown",
            goals = {
                code("Egress on", function(lines)
                    return oneline(play(lines, 11), "^%s*%-%s*Egress%s*$")
                end, 1, "Egress"),
                code("port: 5432", function(lines)
                    return oneline(play(lines, 11), "^%s*port:%s*5432%s*$")
                end, 2, "^%s*port:"),
                code('"TCP"', function(lines)
                    return oneline(play(lines, 11), 'protocol:%s*"TCP"%s*$')
                end, 3, "protocol:"),
                code('"backend"', function(lines)
                    return oneline(play(lines, 11), 'role:%s*"backend"%s*$')
                end, 4, "^%s*role:"),
            },
        },
        {
            id = 12,
            title = "StatefulSet Postgres HA",
            goals = {
                code("replicas: 3", function(lines)
                    return oneline(play(lines, 12), "^%s*replicas:%s*3%s*$")
                end, 1, "^%s*replicas:"),
                code("postgres-headless", function(lines)
                    return oneline(play(lines, 12), 'serviceName:%s*"postgres%-headless"%s*$')
                end, 1, "^%s*serviceName:"),
                code("postgres:16.4-alpine", function(lines)
                    return oneline(play(lines, 12), 'image:%s*"?postgres:16%.4%-alpine"?%s*$')
                end, 2, "^%s*image:"),
                code('storage "50Gi"', function(lines)
                    return oneline(play(lines, 12), 'storage:%s*"50Gi"%s*$')
                end, 3, "^%s*storage:"),
                code("fast-ssd", function(lines)
                    return oneline(play(lines, 12), 'storageClassName:%s*"fast%-ssd"%s*$')
                end, 3, "^%s*storageClassName:"),
                code("PG_DEBUG_SQL off", function(lines)
                    return oneline(play(lines, 12), '^%s*#+%s*PG_DEBUG_SQL:%s*"true"')
                end, 4, "PG_DEBUG_SQL:"),
            },
        },
        {
            id = 13,
            title = "CronJob Backup Incident",
            goals = {
                code('schedule "0 2 * * *"', function(lines)
                    return oneline(play(lines, 13), 'schedule:%s*"0 2 %* %* %*"%s*$')
                end, 1, "^%s*schedule:"),
                code("Forbid", function(lines)
                    return oneline(play(lines, 13), "^%s*concurrencyPolicy:%s*Forbid%s*$")
                end, 2, "^%s*concurrencyPolicy:"),
                code("history: 3", function(lines)
                    return oneline(play(lines, 13), "^%s*successfulJobsHistoryLimit:%s*3%s*$")
                end, 2, "^%s*successfulJobsHistoryLimit:"),
                code("OnFailure", function(lines)
                    return oneline(play(lines, 13), "^%s*restartPolicy:%s*OnFailure%s*$")
                end, 3, "^%s*restartPolicy:"),
                code("obrisi debug_sleep", function(lines)
                    return not play(lines, 13):find("debug_sleep_13", 1, true)
                end, 4, "debug_sleep_13:"),
                code("dry-run off", function(lines)
                    return oneline(play(lines, 13), '^%s*#+%s*%-%s*"%-%-dry%-run"')
                end, 4, "%-%-dry%-run"),
            },
        },
        {
            id = 14,
            title = "PDB & TopologySpread",
            goals = {
                code("minAvailable: 2", function(lines)
                    return oneline(play(lines, 14), "^%s*minAvailable:%s*2%s*$")
                end, 1, "^%s*minAvailable:"),
                code("maxSkew: 1", function(lines)
                    return oneline(play(lines, 14), "^%s*maxSkew:%s*1%s*$")
                end, 1, "^%s*maxSkew:"),
                code("topology zone", function(lines)
                    return oneline(play(lines, 14), 'topologyKey:%s*"topology%.kubernetes%.io/zone"%s*$')
                end, 2, "^%s*topologyKey:"),
                code("DoNotSchedule", function(lines)
                    return oneline(play(lines, 14), "^%s*whenUnsatisfiable:%s*DoNotSchedule%s*$")
                end, 3, "^%s*whenUnsatisfiable:"),
                code("app prvi", function(lines)
                    return yaml_first_child(play(lines, 14), "^%s*matchLabels:%s*$", "app:%s*checkout%s*$")
                end, 4, "^%s*app:%s*checkout"),
            },
        },
        {
            id = 15,
            title = "RBAC Least-Privilege",
            goals = {
                code("secrets off", function(lines)
                    return oneline(play(lines, 15), '^%s*#+%s*%-%s*"secrets"')
                end, 1, '"secrets"'),
                code("delete off", function(lines)
                    return oneline(play(lines, 15), '^%s*#+%s*%-%s*"delete"')
                end, 1, '"delete"'),
                code("obrisi wildcard", function(lines)
                    return not play(lines, 15):find("wildcard_hack_15", 1, true)
                end, 2, "wildcard_hack_15:"),
                code('"pods"', function(lines)
                    return oneline(play(lines, 15), '^%s*%-%s*"pods"%s*$')
                end, 3, "pods"),
                code('"configmaps"', function(lines)
                    return oneline(play(lines, 15), '^%s*%-%s*"configmaps"%s*$')
                end, 3, "configmaps"),
                code("readonly-ops", function(lines)
                    return oneline(play(lines, 15), "^%s*name:%s*readonly%-ops%s*$")
                end, 4, "cluster%-admin"),
            },
        },
        {
            id = 16,
            title = "OpenShift Route & TLS",
            goals = {
                code("ocp-prod host", function(lines)
                    return oneline(play(lines, 16), 'host:%s*"portal%.apps%.ocp%-prod%.internal"%s*$')
                end, 1, "^%s*host:"),
                code("edge", function(lines)
                    return oneline(play(lines, 16), "^%s*termination:%s*edge%s*$")
                end, 2, "^%s*termination:"),
                code("Redirect", function(lines)
                    return oneline(play(lines, 16), "^%s*insecureEdgeTerminationPolicy:%s*Redirect%s*$")
                end, 2, "^%s*insecureEdgeTerminationPolicy:"),
                code("targetPort: 8443", function(lines)
                    return oneline(play(lines, 16), "^%s*targetPort:%s*8443%s*$")
                end, 3, "^%s*targetPort:"),
                code("weight: 100", function(lines)
                    return oneline(play(lines, 16), "^%s*weight:%s*100%s*$")
                end, 3, "^%s*weight:"),
                code("haproxy_debug off", function(lines)
                    return oneline(play(lines, 16), '^%s*#+%s*haproxy_debug:%s*"on"')
                end, 4, "haproxy_debug:"),
            },
        },
        {
            id = 17,
            title = "ArgoCD Auto-Sync & Self-Heal",
            goals = {
                code("ocp_prod svuda", function(lines)
                    local text = play(lines, 17)
                    return not text:find("dev_cluster_17", 1, true) and count_plain(text, "ocp_prod") >= 3
                end, 1, "^%s*project:"),
                code("v3.2.0", function(lines)
                    return oneline(play(lines, 17), 'targetRevision:%s*"v3%.2%.0"%s*$')
                end, 2, "^%s*targetRevision:"),
                code("prune: true", function(lines)
                    return oneline(play(lines, 17), "^%s*prune:%s*true%s*$")
                end, 3, "^%s*prune:"),
                code("selfHeal: true", function(lines)
                    return oneline(play(lines, 17), "^%s*selfHeal:%s*true%s*$")
                end, 3, "^%s*selfHeal:"),
                code("CreateNamespace", function(lines)
                    return oneline(play(lines, 17), "^%s*%-%s*CreateNamespace=true%s*$")
                end, 4, "CreateNamespace=true"),
                code("skipDryRun off", function(lines)
                    return oneline(play(lines, 17), "^%s*#+%s*skipDryRun:%s*true")
                end, 4, "skipDryRun:"),
            },
        },
        {
            id = 18,
            title = "ExternalSecrets & Vault",
            goals = {
                code("vault_prod svuda", function(lines)
                    local text = play(lines, 18)
                    return not text:find("vault_staging_18", 1, true) and count_plain(text, "vault_prod") >= 3
                end, 1, "secretStoreRef:"),
                code('refresh "15m"', function(lines)
                    return oneline(play(lines, 18), 'refreshInterval:%s*"15m"%s*$')
                end, 2, "^%s*refreshInterval:"),
                code("Owner", function(lines)
                    return oneline(play(lines, 18), "^%s*creationPolicy:%s*Owner%s*$")
                end, 3, "^%s*creationPolicy:"),
                code("obrisi leak", function(lines)
                    return not play(lines, 18):find("plaintext_leak_18", 1, true)
                end, 4, "plaintext_leak_18:"),
                code("insecureTLS off", function(lines)
                    return oneline(play(lines, 18), "^%s*#+%s*allowInsecureTLS:%s*true")
                end, 4, "allowInsecureTLS:"),
            },
        },
        {
            id = 19,
            title = "Prometheus 3AM AlertRule",
            goals = {
                code("alert prvi", function(lines)
                    return yaml_first_child(play(lines, 19), "^%s*rules:%s*$", "alert:%s*HighPodRestarts%s*$")
                end, 1, "^%s*alert:"),
                code('for: "5m"', function(lines)
                    return oneline(play(lines, 19), 'for:%s*"5m"%s*$')
                end, 2, "^%s*for:"),
                code('"critical"', function(lines)
                    return oneline(play(lines, 19), 'severity:%s*"critical"%s*$')
                end, 3, "^%s*severity:"),
                code('"sre-platform"', function(lines)
                    return oneline(play(lines, 19), 'team:%s*"sre%-platform"%s*$')
                end, 3, "^%s*team:"),
                code("runbook URL", function(lines)
                    return oneline(play(lines, 19), 'runbook:%s*"https://wiki%.internal/oom"%s*$')
                end, 4, "^%s*runbook:"),
                code("mute off", function(lines)
                    return oneline(play(lines, 19), "^%s*#+%s*mute_all_alerts:%s*true")
                end, 4, "mute_all_alerts:"),
            },
        },
        {
            id = 20,
            title = "DaemonSet Log Collector",
            goals = {
                code("fluent-bit:3.1", function(lines)
                    return oneline(play(lines, 20), 'image:%s*"?fluent/fluent%-bit:3%.1"?%s*$')
                end, 1, "^%s*image:"),
                code("/var/log/containers", function(lines)
                    return oneline(play(lines, 20), 'path:%s*"/var/log/containers"%s*$')
                end, 2, "^%s*path:"),
                code("readOnly: true", function(lines)
                    return oneline(play(lines, 20), "^%s*readOnly:%s*true%s*$")
                end, 2, "^%s*readOnly:"),
                code('"Exists"', function(lines)
                    return oneline(play(lines, 20), 'operator:%s*"Exists"%s*$')
                end, 3, "operator:"),
                code('"NoSchedule"', function(lines)
                    return oneline(play(lines, 20), 'effect:%s*"NoSchedule"%s*$')
                end, 3, "^%s*effect:"),
                code("drop_all_logs off", function(lines)
                    return oneline(play(lines, 20), "^%s*#+%s*drop_all_logs:%s*true")
                end, 4, "drop_all_logs:"),
            },
        },
        {
            id = 21,
            title = "INCIDENT: CrashLoopBackOff",
            goals = {
                code('memory "1Gi"', function(lines)
                    return oneline(play(lines, 21), 'memory:%s*"1Gi"%s*$')
                end, 1, "^%s*memory:"),
                code('cpu "500m"', function(lines)
                    return oneline(play(lines, 21), 'cpu:%s*"500m"%s*$')
                end, 1, "^%s*cpu:"),
                code("initialDelay: 30", function(lines)
                    return oneline(play(lines, 21), "^%s*initialDelaySeconds:%s*30%s*$")
                end, 2, "^%s*initialDelaySeconds:"),
                code("period: 10", function(lines)
                    return oneline(play(lines, 21), "^%s*periodSeconds:%s*10%s*$")
                end, 2, "^%s*periodSeconds:"),
                code("failureThreshold: 5", function(lines)
                    return oneline(play(lines, 21), "^%s*failureThreshold:%s*5%s*$")
                end, 2, "^%s*failureThreshold:"),
                code("obrisi leak sim", function(lines)
                    return not play(lines, 21):find("memory_leak_sim_21", 1, true)
                end, 3, "memory_leak_sim_21:"),
                code("CRASH_ON_START off", function(lines)
                    return oneline(play(lines, 21), '^%s*#+%s*CRASH_ON_START:%s*"1"')
                end, 4, "CRASH_ON_START:"),
            },
        },
        {
            id = 22,
            title = "INCIDENT: CoreDNS Split-Brain",
            goals = {
                code("10.96.0.10 svuda", function(lines)
                    local text = play(lines, 22)
                    return not text:find("broken_dns_22", 1, true) and count_plain(text, "10.96.0.10") >= 2
                end, 1, "^%s*clusterIP:"),
                code("ndots: 2", function(lines)
                    return oneline(play(lines, 22), "^%s*ndots:%s*2%s*$")
                end, 2, "^%s*ndots:"),
                code("ClusterFirst", function(lines)
                    return oneline(play(lines, 22), "^%s*dnsPolicy:%s*ClusterFirst%s*$")
                end, 2, "^%s*dnsPolicy:"),
                code("replicas: 3", function(lines)
                    return oneline(play(lines, 22), "^%s*replicas:%s*3%s*$")
                end, 3, "^%s*replicas:"),
                code("loop_forward off", function(lines)
                    return oneline(play(lines, 22), '^%s*#+%s*loop_forward:%s*"127%.0%.0%.1"')
                end, 3, "loop_forward:"),
                code("upstream_1 prvi", function(lines)
                    return yaml_first_child(play(lines, 22), "^%s*upstreams:%s*$", "upstream_1:")
                end, 4, "^%s*upstream_1:"),
            },
        },
        {
            id = 23,
            title = "INCIDENT: Expired TLS Cert",
            goals = {
                code("letsencrypt-prod", function(lines)
                    return oneline(play(lines, 23), 'name:%s*"letsencrypt%-prod"%s*$')
                end, 1, "letsencrypt"),
                code('duration "2160h"', function(lines)
                    return oneline(play(lines, 23), 'duration:%s*"2160h"%s*$')
                end, 2, "^%s*duration:"),
                code('renewBefore "360h"', function(lines)
                    return oneline(play(lines, 23), 'renewBefore:%s*"360h"%s*$')
                end, 2, "^%s*renewBefore:"),
                code("shop.prod.example.com", function(lines)
                    return oneline(play(lines, 23), 'dnsName:%s*"shop%.prod%.example%.com"%s*$')
                end, 3, "^%s*dnsName:"),
                code("obrisi override", function(lines)
                    return not play(lines, 23):find("expired_override_23", 1, true)
                end, 4, "expired_override_23:"),
                code("selfSigned off", function(lines)
                    return oneline(play(lines, 23), "^%s*#+%s*selfSigned:%s*true")
                end, 4, "selfSigned:"),
            },
        },
        {
            id = 24,
            title = "BOSS 1: Envoy Sidecar Mesh",
            goals = {
                code("prod_mesh svuda", function(lines)
                    local text = play(lines, 24)
                    return not text:find("beta_mesh_24", 1, true) and count_plain(text, "prod_mesh") >= 3
                end, 1, "^%s*namespace:"),
                code("replicas: 4", function(lines)
                    return oneline(play(lines, 24), "^%s*replicas:%s*4%s*$")
                end, 2, "^%s*replicas:"),
                code("runAsNonRoot: true", function(lines)
                    return oneline(play(lines, 24), "^%s*runAsNonRoot:%s*true%s*$")
                end, 2, "^%s*runAsNonRoot:"),
                code("envoy:v1.31", function(lines)
                    return oneline(play(lines, 24), 'image:%s*"?envoyproxy/envoy:v1%.31"?%s*$')
                end, 3, "^%s*image:"),
                code("port 15001", function(lines)
                    return oneline(play(lines, 24), "^%s*%-%s*containerPort:%s*15001%s*$")
                end, 3, "containerPort:"),
                code("ENVOY_LOG off", function(lines)
                    return oneline(play(lines, 24), '^%s*#+%s*ENVOY_LOG_LEVEL:%s*"trace"')
                end, 4, "ENVOY_LOG_LEVEL:"),
                code("obrisi sidecar_junk", function(lines)
                    return not play(lines, 24):find("sidecar_junk_24", 1, true)
                end, 4, "sidecar_junk_24:"),
                code("init -> app -> envoy", function(lines)
                    return ordered_lines(play(lines, 24), {
                        '"init%-config"',
                        '"app"',
                        '"envoy%-sidecar"',
                    })
                end, 5, '"init%-config"'),
            },
        },
        {
            id = 25,
            title = "FINAL K8S BOSS: Prod Cutover",
            goals = {
                code("obrisi trash", function(lines)
                    return not play(lines, 25):find("cutover_trash_25", 1, true)
                end, 1, "cutover_trash_25:"),
                code("prod_v5 svuda (4x)", function(lines)
                    local text = play(lines, 25)
                    return not text:find("rc_alpha_25", 1, true) and count_plain(text, "prod_v5") >= 4
                end, 2, "^%s*image:"),
                code("replicas: 8", function(lines)
                    return oneline(play(lines, 25), "^%s*replicas:%s*8%s*$")
                end, 3, "^%s*replicas:"),
                code("IfNotPresent", function(lines)
                    return oneline(play(lines, 25), "^%s*imagePullPolicy:%s*IfNotPresent%s*$")
                end, 3, "^%s*imagePullPolicy:"),
                code("surround (region/tag/port)", function(lines)
                    local text = play(lines, 25)
                    return oneline(text, 'region:%s*"eu%-central%-1"%s*$')
                        and oneline(text, 'release_tag:%s*"v5%.0%.0"%s*$')
                        and oneline(text, "^%s*%-%s*containerPort:%s*8443%s*$")
                end, 4, "containerPort:"),
                code("runAsNonRoot + Egress + chaos off", function(lines)
                    local text = play(lines, 25)
                    return oneline(text, "^%s*runAsNonRoot:%s*true%s*$")
                        and oneline(text, "^%s*%-%s*Egress%s*$")
                        and oneline(text, "^%s*#+%s*chaos_mode:%s*true")
                end, 5, "chaos_mode:"),
                code("cutover_plan 1..4", function(lines)
                    return yaml_list_slot(play(lines, 25), "^%s*cutover_plan:%s*$", 1, "1. Preflight check")
                        and yaml_list_slot(play(lines, 25), "^%s*cutover_plan:%s*$", 2, "2. DB migration")
                        and yaml_list_slot(play(lines, 25), "^%s*cutover_plan:%s*$", 3, "3. Canary rollout")
                        and yaml_list_slot(play(lines, 25), "^%s*cutover_plan:%s*$", 4, "4. Full cutover")
                end, 6, "^%s*cutover_plan:"),
                code("2x Notify SRE Slack", function(lines)
                    local text = play(lines, 25)
                    return not text:find("FIXME", 1, true)
                        and oneline(text, 'pre_notify:%s*"Notify SRE Slack"%s*$')
                        and oneline(text, 'post_notify:%s*"Notify SRE Slack"%s*$')
                end, 7, "^%s*post_notify:"),
            },
        },
    }
end

function M.ansible(H)
    local play, oneline, ordered_lines, count_plain, code, yaml_list_slot = make_helpers(H)

    return {
        {
            id = 1,
            title = "Playbook Header",
            goals = {
                code("prod_web", function(lines)
                    return oneline(play(lines, 1), "^%s*hosts:%s*prod_web%s*$")
                end, 1, "^%s*hosts:"),
                code("become: true", function(lines)
                    return oneline(play(lines, 1), "^%s*become:%s*true%s*$")
                end, 2, "^%s*become:"),
                code("remote_user", function(lines)
                    return oneline(play(lines, 1), "^%s*remote_user:%s*ansible%s*$")
                end, 3, "^%s*remote_user:"),
                code("obrisi junk", function(lines)
                    return not play(lines, 1):find("junk_option", 1, true)
                end, 4, "junk_option:"),
            },
        },
        {
            id = 2,
            title = "RHEL 9 FQCN Migracija",
            goals = {
                code("dnf", function(lines)
                    local text = play(lines, 2)
                    return oneline(text, "^%s*ansible%.builtin%.dnf:%s*$") and not oneline(text, "^%s*yum:%s*$")
                end, 1, "Install nginx"),
                code("systemd", function(lines)
                    local text = play(lines, 2)
                    return oneline(text, "^%s*ansible%.builtin%.systemd:%s*$") and not oneline(text, "^%s*service:%s*$")
                end, 2, "Ensure nginx is running"),
                code("template", function(lines)
                    local text = play(lines, 2)
                    return oneline(text, "^%s*ansible%.builtin%.template:%s*$") and not oneline(text, "^%s*copy:%s*$")
                end, 3, "Render nginx config"),
            },
        },
        {
            id = 3,
            title = "Task Redosled",
            goals = {
                code("Install -> Deploy -> Start", function(lines)
                    return ordered_lines(play(lines, 3), {
                        "name:%s*Install nginx package",
                        "name:%s*Deploy nginx config",
                        "name:%s*Start and enable nginx",
                    })
                end, nil, "name:%s*Install nginx package"),
            },
        },
        {
            id = 4,
            title = "Jinja2 & Mode Surround",
            goals = {
                code('"{{ app_src }}"', function(lines)
                    return oneline(play(lines, 4), 'src:%s*"{{%s*app_src%s*}}"%s*$')
                end, 1, "^%s*src:"),
                code('dest "..."', function(lines)
                    return oneline(play(lines, 4), 'dest:%s*"/etc/nginx/conf%.d/app%.conf"%s*$')
                end, 2, "^%s*dest:"),
                code('mode "0644"', function(lines)
                    return oneline(play(lines, 4), 'mode:%s*"0644"%s*$')
                end, 3, "^%s*mode:"),
            },
        },
        {
            id = 5,
            title = "Handlers & Notify",
            goals = {
                code("2x notify", function(lines)
                    local text = play(lines, 5)
                    return not text:find('"TODO"', 1, true) and count_plain(text, 'notify: "Restart nginx"') >= 2
                end, 2, "Update TLS config"),
                code("state: restarted", function(lines)
                    return oneline(play(lines, 5), "^%s*state:%s*restarted%s*$")
                end, 3, "^%s*state:"),
            },
        },
        {
            id = 6,
            title = "RHEL 9 Paketi & Repo",
            goals = {
                code("telnet off", function(lines)
                    return oneline(play(lines, 6), "^%s*#+%s*%-%s*telnet")
                end, 1, "telnet"),
                code("state: present", function(lines)
                    return oneline(play(lines, 6), "^%s*state:%s*present%s*$")
                end, 2, "^%s*state:"),
                code("rhel9_baseos", function(lines)
                    local text = play(lines, 6)
                    return not text:find("old_repo_06", 1, true) and count_plain(text, "rhel9_baseos") >= 3
                end, 3, "^%s*enablerepo:"),
            },
        },
        {
            id = 7,
            title = "RHEL 9 Firewalld",
            goals = {
                code("ansible.posix.firewalld", function(lines)
                    local text = play(lines, 7)
                    return oneline(text, "^%s*ansible%.posix%.firewalld:%s*$")
                        and not oneline(text, "^%s*firewalld:%s*$")
                end, 1, "firewalld:"),
                code('"443/tcp"', function(lines)
                    return oneline(play(lines, 7), 'port:%s*"443/tcp"%s*$')
                end, 2, "^%s*port:"),
                code("permanent/immediate/enabled", function(lines)
                    local text = play(lines, 7)
                    return oneline(text, "^%s*permanent:%s*true%s*$")
                        and oneline(text, "^%s*immediate:%s*true%s*$")
                        and oneline(text, "^%s*state:%s*enabled%s*$")
                end, 3, "^%s*state:"),
                code("telnet 23 off", function(lines)
                    return oneline(play(lines, 7), '^%s*#+%s*%-%s*"23/tcp"')
                end, 4, "23/tcp"),
            },
        },
        {
            id = 8,
            title = "SELinux & Sysctl Tuning",
            goals = {
                code("enforcing + targeted", function(lines)
                    local text = play(lines, 8)
                    return oneline(text, "^%s*state:%s*enforcing%s*$") and oneline(text, "^%s*policy:%s*targeted%s*$")
                end, 1, "^%s*state:"),
                code('"net.ipv4.ip_forward"', function(lines)
                    return oneline(play(lines, 8), 'name:%s*"net%.ipv4%.ip_forward"%s*$')
                end, 2, "ip_forward"),
                code('value "1" + reload', function(lines)
                    local text = play(lines, 8)
                    return oneline(text, 'value:%s*"1"%s*$') and oneline(text, "^%s*reload:%s*true%s*$")
                end, 3, "^%s*value:"),
                code("obrisi bypass", function(lines)
                    return not play(lines, 8):find("selinux_bypass_08", 1, true)
                end, 4, "selinux_bypass_08:"),
            },
        },
        {
            id = 9,
            title = "Block / Rescue / Always",
            goals = {
                code("become: true", function(lines)
                    return oneline(play(lines, 9), "^%s*become:%s*true%s*$")
                end, 1, "^%s*become:"),
                code("block -> rescue -> always", function(lines)
                    return ordered_lines(play(lines, 9), {
                        "block:%s*$",
                        "rescue:%s*$",
                        "always:%s*$",
                    })
                end, 2, "block:%s*$"),
                code("failed_when off", function(lines)
                    return oneline(play(lines, 9), "^%s*#+%s*failed_when:%s*false")
                end, 3, "failed_when:"),
                code("Rollback + absent", function(lines)
                    local text = play(lines, 9)
                    return oneline(text, 'msg:%s*"Rollback triggered"%s*$') and oneline(text, "^%s*state:%s*absent%s*$")
                end, 4, "^%s*msg:"),
            },
        },
        {
            id = 10,
            title = "OpenSSH Hardening",
            goals = {
                code("Root & Password no", function(lines)
                    local text = play(lines, 10)
                    return oneline(text, '^%s*%-%s*"PermitRootLogin no"%s*$')
                        and oneline(text, '^%s*%-%s*"PasswordAuthentication no"%s*$')
                end, 1, "PermitRootLogin"),
                code('"Port 2222"', function(lines)
                    return oneline(play(lines, 10), '^%s*%-%s*"Port 2222"%s*$')
                end, 2, "Port 2222"),
                code("sshd -t validate", function(lines)
                    return oneline(play(lines, 10), 'validate:%s*"/usr/sbin/sshd %-t %-f %%s"%s*$')
                end, 3, "^%s*validate:"),
                code("notify + EmptyPass off", function(lines)
                    local text = play(lines, 10)
                    return oneline(text, 'notify:%s*"Restart sshd"%s*$')
                        and oneline(text, '^%s*#+%s*%-%s*"AllowEmptyPasswords yes"')
                end, 4, "^%s*notify:"),
            },
        },
        {
            id = 11,
            title = "Systemd Timer & Indent",
            goals = {
                code("backup-db.timer", function(lines)
                    return oneline(play(lines, 11), '^        name:%s*"backup%-db%.timer"%s*$')
                end, 1, "backup%-db"),
                code("enabled (8 sp)", function(lines)
                    return oneline(play(lines, 11), "^        enabled:%s*true%s*$")
                end, 2, "enabled:"),
                code("daemon_reload (8 sp)", function(lines)
                    return oneline(play(lines, 11), "^        daemon_reload:%s*true%s*$")
                end, 2, "daemon_reload:"),
                code("started (8 sp)", function(lines)
                    return oneline(play(lines, 11), "^        state:%s*started%s*$")
                end, 2, "state:"),
                code("masked: false (8 sp)", function(lines)
                    return oneline(play(lines, 11), "^        masked:%s*false%s*$")
                end, 3, "masked:"),
            },
        },
        {
            id = 12,
            title = "Loop, When & Tags",
            goals = {
                code('when "RedHat"', function(lines)
                    return oneline(play(lines, 12), 'when:%s*ansible_os_family == "RedHat"%s*$')
                end, 1, "^%s*when:"),
                code("loop redosled", function(lines)
                    return ordered_lines(play(lines, 12), {
                        '"ca%-certificates"',
                        '"curl"',
                        '"jq"',
                        '"tmux"',
                    })
                end, 2, '"ca%-certificates"'),
                code("ftp off", function(lines)
                    return oneline(play(lines, 12), '^%s*#+%s*%-%s*"ftp"')
                end, 3, '"ftp"'),
                code('tags ["rhel9", "base"]', function(lines)
                    return oneline(play(lines, 12), 'tags:%s*%[%s*"rhel9"%s*,%s*"base"%s*%]%s*$')
                end, 4, "^%s*tags:"),
            },
        },
        {
            id = 13,
            title = "URI Healthcheck & Retries",
            goals = {
                code("https prod url", function(lines)
                    return oneline(play(lines, 13), 'url:%s*"https://api%.prod%.internal/health"%s*$')
                end, 1, "^%s*url:"),
                code("status_code: 200", function(lines)
                    return oneline(play(lines, 13), "^%s*status_code:%s*200%s*$")
                end, 2, "^%s*status_code:"),
                code("retries 10 / delay 5", function(lines)
                    local text = play(lines, 13)
                    return oneline(text, "^%s*retries:%s*10%s*$") and oneline(text, "^%s*delay:%s*5%s*$")
                end, 3, "^%s*retries:"),
                code("validate_certs + hack off", function(lines)
                    local text = play(lines, 13)
                    return oneline(text, "^%s*validate_certs:%s*true%s*$")
                        and oneline(text, "^%s*#+%s*ignore_tls_hack:%s*true")
                end, 4, "^%s*validate_certs:"),
            },
        },
        {
            id = 14,
            title = "Rootless Podman na RHEL 9",
            goals = {
                code("podman_container", function(lines)
                    local text = play(lines, 14)
                    return oneline(text, "^%s*containers%.podman%.podman_container:%s*$")
                        and not oneline(text, "^%s*docker_container:%s*$")
                end, 1, "_container:"),
                code("agent:v2.1", function(lines)
                    return oneline(play(lines, 14), 'image:%s*"?quay%.io/org/agent:v2%.1"?%s*$')
                end, 2, "^%s*image:"),
                code('started + "always"', function(lines)
                    local text = play(lines, 14)
                    return oneline(text, "^%s*state:%s*started%s*$")
                        and oneline(text, 'restart_policy:%s*"always"%s*$')
                end, 3, "^%s*state:"),
                code('ports + privileged off', function(lines)
                    local text = play(lines, 14)
                    return oneline(text, 'ports:%s*%[%s*"8080:8080"%s*%]%s*$')
                        and oneline(text, "^%s*#+%s*privileged:%s*true")
                end, 4, "^%s*ports:"),
            },
        },
        {
            id = 15,
            title = "HAProxy & Keepalived VIP",
            goals = {
                code("10.50.0.10 svuda", function(lines)
                    local text = play(lines, 15)
                    return not text:find("old_vip_15", 1, true) and count_plain(text, "10.50.0.10") >= 2
                end, 1, "^%s*vip_address:"),
                code("150 / MASTER / 2", function(lines)
                    local text = play(lines, 15)
                    return oneline(text, "^%s*priority:%s*150%s*$")
                        and oneline(text, 'vrrp_state:%s*"MASTER"%s*$')
                        and oneline(text, "^%s*check_interval:%s*2%s*$")
                end, 2, "^%s*priority:"),
                code("nopreempt_bug off", function(lines)
                    return oneline(play(lines, 15), "^%s*#+%s*nopreempt_bug:%s*true")
                end, 3, "nopreempt_bug:"),
                code("haproxy pre keepalived", function(lines)
                    return ordered_lines(play(lines, 15), {
                        "name:%s*Configure haproxy",
                        "name:%s*Configure keepalived",
                    })
                end, 4, "name:%s*Configure haproxy"),
            },
        },
        {
            id = 16,
            title = "SRE User & SSH Key",
            goals = {
                code("sre_admin + wheel", function(lines)
                    local text = play(lines, 16)
                    return oneline(text, 'name:%s*"sre_admin"%s*$') and oneline(text, 'groups:%s*"wheel"%s*$')
                end, 1, "^%s*groups:"),
                code("/bin/bash + present", function(lines)
                    local text = play(lines, 16)
                    return oneline(text, 'shell:%s*"/bin/bash"%s*$') and oneline(text, "^%s*state:%s*present%s*$")
                end, 2, "^%s*shell:"),
                code("exclusive: true", function(lines)
                    return oneline(play(lines, 16), "^%s*exclusive:%s*true%s*$")
                end, 3, "^%s*exclusive:"),
                code("password off", function(lines)
                    return oneline(play(lines, 16), '^%s*#+%s*password:%s*"123456"')
                end, 4, "password:"),
            },
        },
        {
            id = 17,
            title = "Cron Job & Cleanup",
            goals = {
                code("03:30", function(lines)
                    local text = play(lines, 17)
                    return oneline(text, 'minute:%s*"30"%s*$') and oneline(text, 'hour:%s*"3"%s*$')
                end, 1, "^%s*minute:"),
                code('"root" + present', function(lines)
                    local text = play(lines, 17)
                    return oneline(text, 'user:%s*"root"%s*$') and oneline(text, "^%s*state:%s*present%s*$")
                end, 2, "^%s*user:"),
                code("cleanup.sh", function(lines)
                    return oneline(play(lines, 17), 'job:%s*"/usr/local/bin/cleanup%.sh"%s*$')
                end, 3, "^%s*job:"),
                code("disabled off", function(lines)
                    return oneline(play(lines, 17), "^%s*#+%s*disabled:%s*true")
                end, 4, "disabled:"),
            },
        },
        {
            id = 18,
            title = "Template Backup & Validate",
            goals = {
                code("nginx / 0640", function(lines)
                    local text = play(lines, 18)
                    return oneline(text, 'owner:%s*"nginx"%s*$')
                        and oneline(text, 'group:%s*"nginx"%s*$')
                        and oneline(text, 'mode:%s*"0640"%s*$')
                end, 1, "^%s*mode:"),
                code("backup + nginx -t", function(lines)
                    local text = play(lines, 18)
                    return oneline(text, "^%s*backup:%s*true%s*$")
                        and oneline(text, 'validate:%s*"nginx %-t %-c %%s"%s*$')
                end, 2, "^%s*validate:"),
                code("obrisi temp_copy", function(lines)
                    return not play(lines, 18):find("temp_copy_18", 1, true)
                end, 3, "temp_copy_18:"),
            },
        },
        {
            id = 19,
            title = "Git Deploy & changed_when",
            goals = {
                code("v3.5.0", function(lines)
                    return oneline(play(lines, 19), 'version:%s*"v3%.5%.0"%s*$')
                end, 1, "^%s*version:"),
                code("force false + update true", function(lines)
                    local text = play(lines, 19)
                    return oneline(text, "^%s*force:%s*false%s*$") and oneline(text, "^%s*update:%s*true%s*$")
                end, 2, "^%s*force:"),
                code("changed_when + hostkey off", function(lines)
                    local text = play(lines, 19)
                    return oneline(text, "^%s*changed_when:%s*git_result%.changed%s*$")
                        and oneline(text, "^%s*#+%s*accept_hostkey:%s*false")
                end, 3, "^%s*changed_when:"),
            },
        },
        {
            id = 20,
            title = "RHEL 9 Security Patching",
            goals = {
                code("security + bugfix + latest", function(lines)
                    local text = play(lines, 20)
                    return oneline(text, "^%s*security:%s*true%s*$")
                        and oneline(text, "^%s*bugfix:%s*true%s*$")
                        and oneline(text, "^%s*state:%s*latest%s*$")
                end, 1, "^%s*security:"),
                code("timeout 600 / delay 15", function(lines)
                    local text = play(lines, 20)
                    return oneline(text, "^%s*reboot_timeout:%s*600%s*$")
                        and oneline(text, "^%s*pre_reboot_delay:%s*15%s*$")
                end, 2, "^%s*reboot_timeout:"),
                code("force_reboot off", function(lines)
                    return oneline(play(lines, 20), "^%s*#+%s*force_reboot_20:%s*true")
                end, 3, "force_reboot_20:"),
            },
        },
        {
            id = 21,
            title = "INCIDENT: Unsafe Prod Upgrade",
            goals = {
                code("serial 2 / fail 10 / fatal", function(lines)
                    local text = play(lines, 21)
                    return oneline(text, "^%s*serial:%s*2%s*$")
                        and oneline(text, "^%s*max_fail_percentage:%s*10%s*$")
                        and oneline(text, "^%s*any_errors_fatal:%s*true%s*$")
                end, 1, "^%s*serial:"),
                code("force_reboot off", function(lines)
                    return oneline(play(lines, 21), "^%s*#+%s*force_reboot_all:%s*true")
                end, 2, "force_reboot_all:"),
                code("2x quorum check", function(lines)
                    local text = play(lines, 21)
                    return not text:find("TODO_CHECK", 1, true) and count_plain(text, '"Verify cluster quorum"') >= 3
                end, 3, "post_tasks:"),
                code("Backup pre Upgrade", function(lines)
                    return ordered_lines(play(lines, 21), {
                        "name:%s*Backup etcd",
                        "name:%s*Upgrade kubeadm",
                    })
                end, 4, "name:%s*Backup etcd"),
            },
        },
        {
            id = 22,
            title = "INCIDENT: Vault Secrets Leak",
            goals = {
                code("vault_prod svuda", function(lines)
                    local text = play(lines, 22)
                    return not text:find("vault_old_22", 1, true) and count_plain(text, "vault_prod") >= 2
                end, 1, "^%s*vault_id:"),
                code("gather_facts + no_log", function(lines)
                    local text = play(lines, 22)
                    return oneline(text, "^%s*gather_facts:%s*true%s*$") and oneline(text, "^%s*no_log:%s*true%s*$")
                end, 2, "^%s*no_log:"),
                code('mode "0600"', function(lines)
                    return oneline(play(lines, 22), 'mode:%s*"0600"%s*$')
                end, 3, "^%s*mode:"),
                code("debug_print off", function(lines)
                    return oneline(play(lines, 22), "^%s*#+%s*debug_print_secret:%s*true")
                end, 4, "debug_print_secret:"),
            },
        },
        {
            id = 23,
            title = "BOSS 1: Rolling Deploy",
            goals = {
                code("serial: 1 + become: true", function(lines)
                    local text = play(lines, 23)
                    return oneline(text, "^%s*serial:%s*1%s*$") and oneline(text, "^%s*become:%s*true%s*$")
                end, 1, "^%s*serial:"),
                code("ignore_errors off", function(lines)
                    return oneline(play(lines, 23), "^%s*#+%s*ignore_errors:%s*true")
                end, 2, "ignore_errors:"),
                code("Drain -> Upgrade -> Enable", function(lines)
                    return ordered_lines(play(lines, 23), {
                        "name:%s*Drain node",
                        "name:%s*Upgrade app",
                        "name:%s*Enable node",
                    })
                end, 3, "name:%s*Drain node"),
                code("notify haproxy", function(lines)
                    return oneline(play(lines, 23), 'notify:%s*"Reload haproxy"%s*$')
                end, 4, "^%s*notify:"),
            },
        },
        {
            id = 24,
            title = "BOSS 2: RHEL 9 Web+DB Role",
            goals = {
                code("rhel9_prod + become + serial + enforcing", function(lines)
                    local text = play(lines, 24)
                    return oneline(text, "^%s*hosts:%s*rhel9_prod%s*$")
                        and oneline(text, "^%s*become:%s*true%s*$")
                        and oneline(text, "^%s*serial:%s*1%s*$")
                        and oneline(text, "^%s*selinux_state:%s*enforcing%s*$")
                end, 1, "^%s*hosts:"),
                code("dnf + systemd FQCN", function(lines)
                    local text = play(lines, 24)
                    return oneline(text, "^%s*ansible%.builtin%.dnf:%s*$")
                        and oneline(text, "^%s*ansible%.builtin%.systemd:%s*$")
                        and not oneline(text, "^%s*yum:%s*$")
                        and not oneline(text, "^%s*service:%s*$")
                end, 2, "Install packages"),
                code("legacy obrisan + fw off", function(lines)
                    local text = play(lines, 24)
                    return not text:find("legacy_hack_24", 1, true)
                        and oneline(text, "^%s*#+%s*disable_firewall:%s*true")
                end, 3, "disable_firewall:"),
                code("2x notify Reload nginx", function(lines)
                    local text = play(lines, 24)
                    return not text:find('"TODO"', 1, true) and count_plain(text, 'notify: "Reload nginx"') >= 2
                end, 4, "Ensure service started"),
                code("phases 1..4", function(lines)
                    return yaml_list_slot(play(lines, 24), "^%s*phases:%s*$", 1, "1. Firewall")
                        and yaml_list_slot(play(lines, 24), "^%s*phases:%s*$", 2, "2. Packages")
                        and yaml_list_slot(play(lines, 24), "^%s*phases:%s*$", 3, "3. Config")
                        and yaml_list_slot(play(lines, 24), "^%s*phases:%s*$", 4, "4. Start")
                end, 5, "^%s*phases:"),
            },
        },
        {
            id = 25,
            title = "FINAL ANSIBLE BOSS: Cutover",
            goals = {
                code("obrisi trash", function(lines)
                    return not play(lines, 25):find("cutover_trash_25", 1, true)
                end, 1, "cutover_trash_25:"),
                code("prod_v5 svuda (4x)", function(lines)
                    local text = play(lines, 25)
                    return not text:find("rc_alpha_25", 1, true) and count_plain(text, "prod_v5") >= 4
                end, 2, "^%s*hosts:"),
                code("serial: 1 + retries: 5", function(lines)
                    local text = play(lines, 25)
                    return oneline(text, "^%s*serial:%s*1%s*$") and oneline(text, "^%s*retries:%s*5%s*$")
                end, 3, "^%s*retries:"),
                code("surround (region/mode/port)", function(lines)
                    local text = play(lines, 25)
                    return oneline(text, 'region:%s*"eu%-central%-1"%s*$')
                        and oneline(text, 'config_mode:%s*"0600"%s*$')
                        and oneline(text, "^%s*listen_port:%s*8443%s*$")
                end, 4, "^%s*listen_port:"),
                code("become + no_log + chaos off", function(lines)
                    local text = play(lines, 25)
                    return oneline(text, "^%s*become:%s*true%s*$")
                        and oneline(text, "^%s*no_log:%s*true%s*$")
                        and oneline(text, "^%s*#+%s*chaos_mode:%s*true")
                end, 5, "chaos_mode:"),
                code("cutover_plan 1..4", function(lines)
                    return yaml_list_slot(play(lines, 25), "^%s*cutover_plan:%s*$", 1, "1. Preflight check")
                        and yaml_list_slot(play(lines, 25), "^%s*cutover_plan:%s*$", 2, "2. DB migration")
                        and yaml_list_slot(play(lines, 25), "^%s*cutover_plan:%s*$", 3, "3. Canary rollout")
                        and yaml_list_slot(play(lines, 25), "^%s*cutover_plan:%s*$", 4, "4. Full cutover")
                end, 6, "^%s*cutover_plan:"),
                code("2x Notify SRE Slack", function(lines)
                    local text = play(lines, 25)
                    return not text:find("FIXME", 1, true) and count_plain(text, 'notify: "Notify SRE Slack"') >= 2
                end, 7, "Verify cutover health"),
            },
        },
    }
end

return M
