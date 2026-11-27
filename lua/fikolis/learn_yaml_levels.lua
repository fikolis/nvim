-- Level definitions for learning/learn_nvim.yaml (DevOps: Kubernetes & Ansible Dojo).

local function build_levels(H)
    local play = H.play
    local oneline = H.oneline
    local ordered_lines = H.ordered_lines
    local count_plain = H.count_plain
    local code = H.code

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

    return {
        {
            id = 1,
            title = "K8s Scale & Image",
            goals = {
                code("replicas: 3", function(lines)
                    return oneline(play(lines, 1), "^%s*replicas:%s*3%s*$")
                end, 1, "^%s*replicas:"),
                code("nginx:1.27", function(lines)
                    return oneline(play(lines, 1), 'image:%s*"nginx:1%.27"%s*$')
                end, 2, "^%s*image:"),
                code("IfNotPresent", function(lines)
                    return oneline(play(lines, 1), "^%s*imagePullPolicy:%s*IfNotPresent%s*$")
                end, 3, "^%s*imagePullPolicy:"),
            },
        },
        {
            id = 2,
            title = "K8s Env Paste",
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
            title = "K8s Probes & Komentari",
            goals = {
                code("port 9999", function(lines)
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
            title = "K8s Init Redosled",
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
            title = "K8s Namespace Zamena",
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
            title = "K8s ConfigMap Surround",
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
            title = "K8s Void Delete",
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
            title = "K8s YAML Indent",
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
            title = "K8s Security Hardening",
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
            title = "K8s Ingress & HPA",
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
            title = "Ansible Playbook Header",
            goals = {
                code("prod_web", function(lines)
                    return oneline(play(lines, 11), "^%s*hosts:%s*prod_web%s*$")
                end, 1, "^%s*hosts:"),
                code("become: true", function(lines)
                    return oneline(play(lines, 11), "^%s*become:%s*true%s*$")
                end, 2, "^%s*become:"),
                code("remote_user", function(lines)
                    return oneline(play(lines, 11), "^%s*remote_user:%s*ansible%s*$")
                end, 3, "^%s*remote_user:"),
                code("obrisi junk", function(lines)
                    return not play(lines, 11):find("junk_option", 1, true)
                end, 4, "junk_option:"),
            },
        },
        {
            id = 12,
            title = "Ansible FQCN (RHEL 9)",
            goals = {
                code("dnf", function(lines)
                    local text = play(lines, 12)
                    return oneline(text, "^%s*ansible%.builtin%.dnf:%s*$") and not oneline(text, "^%s*yum:%s*$")
                end, 1, "Install nginx"),
                code("systemd", function(lines)
                    local text = play(lines, 12)
                    return oneline(text, "^%s*ansible%.builtin%.systemd:%s*$") and not oneline(text, "^%s*service:%s*$")
                end, 2, "Ensure nginx is running"),
                code("template", function(lines)
                    local text = play(lines, 12)
                    return oneline(text, "^%s*ansible%.builtin%.template:%s*$") and not oneline(text, "^%s*copy:%s*$")
                end, 3, "Render nginx config"),
            },
        },
        {
            id = 13,
            title = "Ansible Task Redosled",
            goals = {
                code("Install -> Deploy -> Start", function(lines)
                    return ordered_lines(play(lines, 13), {
                        "name:%s*Install nginx package",
                        "name:%s*Deploy nginx config",
                        "name:%s*Start and enable nginx",
                    })
                end, nil, "name:%s*Install nginx package"),
            },
        },
        {
            id = 14,
            title = "Ansible Jinja2 Surround",
            goals = {
                code('"{{ app_src }}"', function(lines)
                    return oneline(play(lines, 14), 'src:%s*"{{%s*app_src%s*}}"%s*$')
                end, 1, "^%s*src:"),
                code('dest "..."', function(lines)
                    return oneline(play(lines, 14), 'dest:%s*"/etc/nginx/conf%.d/app%.conf"%s*$')
                end, 2, "^%s*dest:"),
                code('mode "0644"', function(lines)
                    return oneline(play(lines, 14), 'mode:%s*"0644"%s*$')
                end, 3, "^%s*mode:"),
            },
        },
        {
            id = 15,
            title = "Ansible Handlers & Notify",
            goals = {
                code("2x notify", function(lines)
                    local text = play(lines, 15)
                    return not text:find('"TODO"', 1, true)
                        and count_plain(text, 'notify: "Restart nginx"') >= 2
                end, 2, "Update TLS config"),
                code("state: restarted", function(lines)
                    return oneline(play(lines, 15), "^%s*state:%s*restarted%s*$")
                end, 3, "^%s*state:"),
            },
        },
        {
            id = 16,
            title = "Ansible RHEL 9 Paketi",
            goals = {
                code("telnet off", function(lines)
                    return oneline(play(lines, 16), "^%s*#+%s*%-%s*telnet")
                end, 1, "telnet"),
                code("state: present", function(lines)
                    return oneline(play(lines, 16), "^%s*state:%s*present%s*$")
                end, 2, "^%s*state:"),
                code("rhel9_baseos", function(lines)
                    local text = play(lines, 16)
                    return not text:find("old_repo_16", 1, true) and count_plain(text, "rhel9_baseos") >= 3
                end, 3, "^%s*enablerepo:"),
            },
        },
        {
            id = 17,
            title = "K8s NetworkPolicy",
            goals = {
                code("Egress on", function(lines)
                    return oneline(play(lines, 17), "^%s*%-%s*Egress%s*$")
                end, 1, "Egress"),
                code("port: 5432", function(lines)
                    return oneline(play(lines, 17), "^%s*port:%s*5432%s*$")
                end, 2, "^%s*port:"),
                code('"TCP"', function(lines)
                    return oneline(play(lines, 17), 'protocol:%s*"TCP"%s*$')
                end, 3, "^%s*protocol:"),
                code('"backend"', function(lines)
                    return oneline(play(lines, 17), 'role:%s*"backend"%s*$')
                end, 4, "^%s*role:"),
            },
        },
        {
            id = 18,
            title = "DevOps Boss 1 (K8s)",
            goals = {
                code("prod_pay svuda", function(lines)
                    local text = play(lines, 18)
                    return not text:find("staging_pay_18", 1, true) and count_plain(text, "prod_pay") >= 3
                end, 1, "^%s*namespace:"),
                code("replicas: 3", function(lines)
                    return oneline(play(lines, 18), "^%s*replicas:%s*3%s*$")
                end, 2, "^%s*replicas:"),
                code("image v2.4.0", function(lines)
                    return oneline(play(lines, 18), 'image:%s*"registry%.internal/payments:v2%.4%.0"%s*$')
                end, 3, "^%s*image:"),
                code("runAsNonRoot", function(lines)
                    return oneline(play(lines, 18), "^%s*runAsNonRoot:%s*true%s*$")
                end, 4, "runAsNonRoot:"),
                code("port 8443", function(lines)
                    return oneline(play(lines, 18), "^%s*%-%s*containerPort:%s*8443%s*$")
                end, 4, "containerPort:"),
                code("DEBUG_MODE off", function(lines)
                    return oneline(play(lines, 18), '^%s*#+%s*DEBUG_MODE:%s*"true"')
                end, 5, "DEBUG_MODE:"),
            },
        },
        {
            id = 19,
            title = "DevOps Boss 2 (Ansible)",
            goals = {
                code("serial: 1", function(lines)
                    return oneline(play(lines, 19), "^%s*serial:%s*1%s*$")
                end, 1, "^%s*serial:"),
                code("become: true", function(lines)
                    return oneline(play(lines, 19), "^%s*become:%s*true%s*$")
                end, 1, "^%s*become:"),
                code("ignore_errors off", function(lines)
                    return oneline(play(lines, 19), "^%s*#+%s*ignore_errors:%s*true")
                end, 2, "ignore_errors:"),
                code("Drain -> Upgrade -> Enable", function(lines)
                    return ordered_lines(play(lines, 19), {
                        "name:%s*Drain node",
                        "name:%s*Upgrade app",
                        "name:%s*Enable node",
                    })
                end, 3, "name:%s*Drain node"),
                code("notify haproxy", function(lines)
                    return oneline(play(lines, 19), 'notify:%s*"Reload haproxy"%s*$')
                end, 4, "^%s*notify:"),
            },
        },
        {
            id = 20,
            title = "Final DevOps Boss",
            goals = {
                code("obrisi trash", function(lines)
                    return not play(lines, 20):find("trash_flag_20", 1, true)
                end, 1, "trash_flag_20:"),
                code("stable_v2 svuda", function(lines)
                    local text = play(lines, 20)
                    return not text:find("canary_v1", 1, true) and count_plain(text, "stable_v2") >= 3
                end, 2, "^%s*image:"),
                code("replicas: 5", function(lines)
                    return oneline(play(lines, 20), "^%s*replicas:%s*5%s*$")
                end, 3, "^%s*replicas:"),
                code('"production"', function(lines)
                    return oneline(play(lines, 20), 'env:%s*"production"%s*$')
                end, 4, "^%s*env:"),
                code("port: 443", function(lines)
                    return oneline(play(lines, 20), "^%s*port:%s*443%s*$")
                end, 4, "^%s*port:"),
                code("dry_run off", function(lines)
                    return oneline(play(lines, 20), "^%s*#+%s*dry_run:%s*true")
                end, 5, "dry_run:"),
                code("tier prvi", function(lines)
                    return yaml_first_child(play(lines, 20), "^%s*labels:%s*$", 'tier:%s*"critical"')
                end, 5, "^%s*tier:"),
            },
        },
        {
            id = 21,
            title = "K8s StatefulSet Postgres HA",
            goals = {
                code("replicas: 3", function(lines)
                    return oneline(play(lines, 21), "^%s*replicas:%s*3%s*$")
                end, 1, "^%s*replicas:"),
                code("postgres-headless", function(lines)
                    return oneline(play(lines, 21), 'serviceName:%s*"postgres%-headless"%s*$')
                end, 1, "^%s*serviceName:"),
                code("postgres:16.4-alpine", function(lines)
                    return oneline(play(lines, 21), 'image:%s*"postgres:16%.4%-alpine"%s*$')
                end, 2, "^%s*image:"),
                code('storage "50Gi"', function(lines)
                    return oneline(play(lines, 21), 'storage:%s*"50Gi"%s*$')
                end, 3, "^%s*storage:"),
                code("fast-ssd", function(lines)
                    return oneline(play(lines, 21), 'storageClassName:%s*"fast%-ssd"%s*$')
                end, 3, "^%s*storageClassName:"),
                code("PG_DEBUG_SQL off", function(lines)
                    return oneline(play(lines, 21), '^%s*#+%s*PG_DEBUG_SQL:%s*"true"')
                end, 4, "PG_DEBUG_SQL:"),
            },
        },
        {
            id = 22,
            title = "K8s CronJob Backup Incident",
            goals = {
                code('schedule "0 2 * * *"', function(lines)
                    return oneline(play(lines, 22), 'schedule:%s*"0 2 %* %* %*"%s*$')
                end, 1, "^%s*schedule:"),
                code("Forbid", function(lines)
                    return oneline(play(lines, 22), "^%s*concurrencyPolicy:%s*Forbid%s*$")
                end, 2, "^%s*concurrencyPolicy:"),
                code("history: 3", function(lines)
                    return oneline(play(lines, 22), "^%s*successfulJobsHistoryLimit:%s*3%s*$")
                end, 2, "^%s*successfulJobsHistoryLimit:"),
                code("OnFailure", function(lines)
                    return oneline(play(lines, 22), "^%s*restartPolicy:%s*OnFailure%s*$")
                end, 3, "^%s*restartPolicy:"),
                code("obrisi debug_sleep", function(lines)
                    return not play(lines, 22):find("debug_sleep_22", 1, true)
                end, 4, "debug_sleep_22:"),
                code("dry-run off", function(lines)
                    return oneline(play(lines, 22), '^%s*#+%s*%-%s*"%-%-dry%-run"')
                end, 4, "%-%-dry%-run"),
            },
        },
        {
            id = 23,
            title = "K8s PDB & TopologySpread",
            goals = {
                code("minAvailable: 2", function(lines)
                    return oneline(play(lines, 23), "^%s*minAvailable:%s*2%s*$")
                end, 1, "^%s*minAvailable:"),
                code("maxSkew: 1", function(lines)
                    return oneline(play(lines, 23), "^%s*maxSkew:%s*1%s*$")
                end, 1, "^%s*maxSkew:"),
                code("topology zone", function(lines)
                    return oneline(play(lines, 23), 'topologyKey:%s*"topology%.kubernetes%.io/zone"%s*$')
                end, 2, "^%s*topologyKey:"),
                code("DoNotSchedule", function(lines)
                    return oneline(play(lines, 23), "^%s*whenUnsatisfiable:%s*DoNotSchedule%s*$")
                end, 3, "^%s*whenUnsatisfiable:"),
                code("app prvi", function(lines)
                    return yaml_first_child(play(lines, 23), "^%s*matchLabels:%s*$", "app:%s*checkout%s*$")
                end, 4, "^%s*app:%s*checkout"),
            },
        },
        {
            id = 24,
            title = "K8s RBAC Least-Privilege",
            goals = {
                code("secrets off", function(lines)
                    return oneline(play(lines, 24), '^%s*#+%s*%-%s*"secrets"')
                end, 1, '"secrets"'),
                code("delete off", function(lines)
                    return oneline(play(lines, 24), '^%s*#+%s*%-%s*"delete"')
                end, 1, '"delete"'),
                code("obrisi wildcard", function(lines)
                    return not play(lines, 24):find("wildcard_hack_24", 1, true)
                end, 2, "wildcard_hack_24:"),
                code('"pods"', function(lines)
                    return oneline(play(lines, 24), '^%s*%-%s*"pods"%s*$')
                end, 3, "pods"),
                code('"configmaps"', function(lines)
                    return oneline(play(lines, 24), '^%s*%-%s*"configmaps"%s*$')
                end, 3, "configmaps"),
                code("readonly-ops", function(lines)
                    return oneline(play(lines, 24), "^%s*name:%s*readonly%-ops%s*$")
                end, 4, "cluster%-admin"),
            },
        },
        {
            id = 25,
            title = "OpenShift Route & TLS",
            goals = {
                code("ocp-prod host", function(lines)
                    return oneline(play(lines, 25), 'host:%s*"portal%.apps%.ocp%-prod%.internal"%s*$')
                end, 1, "^%s*host:"),
                code("edge", function(lines)
                    return oneline(play(lines, 25), "^%s*termination:%s*edge%s*$")
                end, 2, "^%s*termination:"),
                code("Redirect", function(lines)
                    return oneline(play(lines, 25), "^%s*insecureEdgeTerminationPolicy:%s*Redirect%s*$")
                end, 2, "^%s*insecureEdgeTerminationPolicy:"),
                code("targetPort: 8443", function(lines)
                    return oneline(play(lines, 25), "^%s*targetPort:%s*8443%s*$")
                end, 3, "^%s*targetPort:"),
                code("weight: 100", function(lines)
                    return oneline(play(lines, 25), "^%s*weight:%s*100%s*$")
                end, 3, "^%s*weight:"),
                code("haproxy_debug off", function(lines)
                    return oneline(play(lines, 25), '^%s*#+%s*haproxy_debug:%s*"on"')
                end, 4, "haproxy_debug:"),
            },
        },
        {
            id = 26,
            title = "ArgoCD Auto-Sync & Self-Heal",
            goals = {
                code("ocp_prod svuda", function(lines)
                    local text = play(lines, 26)
                    return not text:find("dev_cluster_26", 1, true) and count_plain(text, "ocp_prod") >= 3
                end, 1, "^%s*project:"),
                code("v3.2.0", function(lines)
                    return oneline(play(lines, 26), 'targetRevision:%s*"v3%.2%.0"%s*$')
                end, 2, "^%s*targetRevision:"),
                code("prune: true", function(lines)
                    return oneline(play(lines, 26), "^%s*prune:%s*true%s*$")
                end, 3, "^%s*prune:"),
                code("selfHeal: true", function(lines)
                    return oneline(play(lines, 26), "^%s*selfHeal:%s*true%s*$")
                end, 3, "^%s*selfHeal:"),
                code("CreateNamespace", function(lines)
                    return oneline(play(lines, 26), "^%s*%-%s*CreateNamespace=true%s*$")
                end, 4, "CreateNamespace=true"),
                code("skipDryRun off", function(lines)
                    return oneline(play(lines, 26), "^%s*#+%s*skipDryRun:%s*true")
                end, 4, "skipDryRun:"),
            },
        },
        {
            id = 27,
            title = "Helm values.yaml Override",
            goals = {
                code("replicaCount: 4", function(lines)
                    return oneline(play(lines, 27), "^%s*replicaCount:%s*4%s*$")
                end, 1, "^%s*replicaCount:"),
                code('tag "v4.1.0"', function(lines)
                    return oneline(play(lines, 27), 'tag:%s*"v4%.1%.0"%s*$')
                end, 2, "^%s*tag:"),
                code('appVersion "v4.1.0"', function(lines)
                    return oneline(play(lines, 27), 'appVersion:%s*"v4%.1%.0"%s*$')
                end, 2, "^%s*appVersion:"),
                code("IfNotPresent", function(lines)
                    return oneline(play(lines, 27), "^%s*pullPolicy:%s*IfNotPresent%s*$")
                end, 3, "^%s*pullPolicy:"),
                code("ingress enabled", function(lines)
                    return oneline(play(lines, 27), "^%s*enabled:%s*true%s*$")
                end, 3, "^%s*enabled:"),
                code("tls indent (2/4 sp)", function(lines)
                    local text = play(lines, 27)
                    return oneline(text, "^  tls:%s*$") and oneline(text, '^    secretName:%s*"gateway%-tls"%s*$')
                end, 4, "tls:"),
            },
        },
        {
            id = 28,
            title = "ExternalSecrets & Vault",
            goals = {
                code("vault_prod svuda", function(lines)
                    local text = play(lines, 28)
                    return not text:find("vault_staging_28", 1, true) and count_plain(text, "vault_prod") >= 3
                end, 1, "secretStoreRef:"),
                code('refresh "15m"', function(lines)
                    return oneline(play(lines, 28), 'refreshInterval:%s*"15m"%s*$')
                end, 2, "^%s*refreshInterval:"),
                code("Owner", function(lines)
                    return oneline(play(lines, 28), "^%s*creationPolicy:%s*Owner%s*$")
                end, 3, "^%s*creationPolicy:"),
                code("obrisi leak", function(lines)
                    return not play(lines, 28):find("plaintext_leak_28", 1, true)
                end, 4, "plaintext_leak_28:"),
                code("insecureTLS off", function(lines)
                    return oneline(play(lines, 28), "^%s*#+%s*allowInsecureTLS:%s*true")
                end, 4, "allowInsecureTLS:"),
            },
        },
        {
            id = 29,
            title = "Prometheus 3AM AlertRule",
            goals = {
                code("alert prvi", function(lines)
                    return yaml_first_child(play(lines, 29), "^%s*rules:%s*$", "alert:%s*HighPodRestarts%s*$")
                end, 1, "^%s*alert:"),
                code('for: "5m"', function(lines)
                    return oneline(play(lines, 29), 'for:%s*"5m"%s*$')
                end, 2, "^%s*for:"),
                code('"critical"', function(lines)
                    return oneline(play(lines, 29), 'severity:%s*"critical"%s*$')
                end, 3, "^%s*severity:"),
                code('"sre-platform"', function(lines)
                    return oneline(play(lines, 29), 'team:%s*"sre%-platform"%s*$')
                end, 3, "^%s*team:"),
                code("runbook URL", function(lines)
                    return oneline(play(lines, 29), 'runbook:%s*"https://wiki%.internal/oom"%s*$')
                end, 4, "^%s*runbook:"),
                code("mute off", function(lines)
                    return oneline(play(lines, 29), "^%s*#+%s*mute_all_alerts:%s*true")
                end, 4, "mute_all_alerts:"),
            },
        },
        {
            id = 30,
            title = "K8s DaemonSet Log Collector",
            goals = {
                code("fluent-bit:3.1", function(lines)
                    return oneline(play(lines, 30), 'image:%s*"fluent/fluent%-bit:3%.1"%s*$')
                end, 1, "^%s*image:"),
                code("/var/log/containers", function(lines)
                    return oneline(play(lines, 30), 'path:%s*"/var/log/containers"%s*$')
                end, 2, "^%s*path:"),
                code("readOnly: true", function(lines)
                    return oneline(play(lines, 30), "^%s*readOnly:%s*true%s*$")
                end, 2, "^%s*readOnly:"),
                code('"Exists"', function(lines)
                    return oneline(play(lines, 30), 'operator:%s*"Exists"%s*$')
                end, 3, "operator:"),
                code('"NoSchedule"', function(lines)
                    return oneline(play(lines, 30), 'effect:%s*"NoSchedule"%s*$')
                end, 3, "^%s*effect:"),
                code("drop_all_logs off", function(lines)
                    return oneline(play(lines, 30), "^%s*#+%s*drop_all_logs:%s*true")
                end, 4, "drop_all_logs:"),
            },
        },
        {
            id = 31,
            title = "Ansible RHEL 9 Firewalld",
            goals = {
                code("ansible.posix.firewalld", function(lines)
                    local text = play(lines, 31)
                    return oneline(text, "^%s*ansible%.posix%.firewalld:%s*$")
                        and not oneline(text, "^%s*firewalld:%s*$")
                end, 1, "firewalld:"),
                code('"443/tcp"', function(lines)
                    return oneline(play(lines, 31), 'port:%s*"443/tcp"%s*$')
                end, 2, "^%s*port:"),
                code("permanent: true", function(lines)
                    return oneline(play(lines, 31), "^%s*permanent:%s*true%s*$")
                end, 3, "^%s*permanent:"),
                code("immediate: true", function(lines)
                    return oneline(play(lines, 31), "^%s*immediate:%s*true%s*$")
                end, 3, "^%s*immediate:"),
                code("state: enabled", function(lines)
                    return oneline(play(lines, 31), "^%s*state:%s*enabled%s*$")
                end, 3, "^%s*state:"),
                code("telnet 23 off", function(lines)
                    return oneline(play(lines, 31), '^%s*#+%s*%-%s*"23/tcp"')
                end, 4, "23/tcp"),
            },
        },
        {
            id = 32,
            title = "Ansible SELinux & Sysctl",
            goals = {
                code("enforcing", function(lines)
                    return oneline(play(lines, 32), "^%s*state:%s*enforcing%s*$")
                end, 1, "^%s*state:"),
                code("targeted", function(lines)
                    return oneline(play(lines, 32), "^%s*policy:%s*targeted%s*$")
                end, 1, "^%s*policy:"),
                code('"net.ipv4.ip_forward"', function(lines)
                    return oneline(play(lines, 32), 'name:%s*"net%.ipv4%.ip_forward"%s*$')
                end, 2, "ip_forward"),
                code('value: "1"', function(lines)
                    return oneline(play(lines, 32), 'value:%s*"1"%s*$')
                end, 3, "^%s*value:"),
                code("reload: true", function(lines)
                    return oneline(play(lines, 32), "^%s*reload:%s*true%s*$")
                end, 3, "^%s*reload:"),
                code("obrisi bypass", function(lines)
                    return not play(lines, 32):find("selinux_bypass_32", 1, true)
                end, 4, "selinux_bypass_32:"),
            },
        },
        {
            id = 33,
            title = "Ansible Block/Rescue/Always",
            goals = {
                code("become: true", function(lines)
                    return oneline(play(lines, 33), "^%s*become:%s*true%s*$")
                end, 1, "^%s*become:"),
                code("block -> rescue -> always", function(lines)
                    return ordered_lines(play(lines, 33), {
                        "block:%s*$",
                        "rescue:%s*$",
                        "always:%s*$",
                    })
                end, 2, "block:%s*$"),
                code("failed_when off", function(lines)
                    return oneline(play(lines, 33), "^%s*#+%s*failed_when:%s*false")
                end, 3, "failed_when:"),
                code("Rollback msg", function(lines)
                    return oneline(play(lines, 33), 'msg:%s*"Rollback triggered"%s*$')
                end, 4, "^%s*msg:"),
                code("state: absent", function(lines)
                    return oneline(play(lines, 33), "^%s*state:%s*absent%s*$")
                end, 4, "^%s*state:"),
            },
        },
        {
            id = 34,
            title = "Ansible SSH Hardening",
            goals = {
                code("PermitRootLogin no", function(lines)
                    return oneline(play(lines, 34), '^%s*%-%s*"PermitRootLogin no"%s*$')
                end, 1, "PermitRootLogin"),
                code("PasswordAuth no", function(lines)
                    return oneline(play(lines, 34), '^%s*%-%s*"PasswordAuthentication no"%s*$')
                end, 1, "PasswordAuthentication"),
                code('"Port 2222"', function(lines)
                    return oneline(play(lines, 34), '^%s*%-%s*"Port 2222"%s*$')
                end, 2, "Port 2222"),
                code("sshd -t validate", function(lines)
                    return oneline(play(lines, 34), 'validate:%s*"/usr/sbin/sshd %-t %-f %%s"%s*$')
                end, 3, "^%s*validate:"),
                code("notify Restart sshd", function(lines)
                    return oneline(play(lines, 34), 'notify:%s*"Restart sshd"%s*$')
                end, 4, "^%s*notify:"),
                code("EmptyPasswords off", function(lines)
                    return oneline(play(lines, 34), '^%s*#+%s*%-%s*"AllowEmptyPasswords yes"')
                end, 4, "AllowEmptyPasswords"),
            },
        },
        {
            id = 35,
            title = "Ansible Systemd Timer & Indent",
            goals = {
                code("backup-db.timer", function(lines)
                    return oneline(play(lines, 35), '^        name:%s*"backup%-db%.timer"%s*$')
                end, 1, "backup%-db"),
                code("enabled (8 sp)", function(lines)
                    return oneline(play(lines, 35), "^        enabled:%s*true%s*$")
                end, 2, "enabled:"),
                code("daemon_reload (8 sp)", function(lines)
                    return oneline(play(lines, 35), "^        daemon_reload:%s*true%s*$")
                end, 2, "daemon_reload:"),
                code("started (8 sp)", function(lines)
                    return oneline(play(lines, 35), "^        state:%s*started%s*$")
                end, 2, "state:"),
                code("masked: false (8 sp)", function(lines)
                    return oneline(play(lines, 35), "^        masked:%s*false%s*$")
                end, 3, "masked:"),
            },
        },
        {
            id = 36,
            title = "Ansible YAML Inventory",
            goals = {
                code("prod_eu1 svuda", function(lines)
                    local text = play(lines, 36)
                    return not text:find("lab_dc_36", 1, true) and count_plain(text, "prod_eu1") >= 5
                end, 1, "^%s*datacenter:"),
                code("port: 22", function(lines)
                    return oneline(play(lines, 36), "^%s*ansible_port:%s*22%s*$")
                end, 2, "^%s*ansible_port:"),
                code('user: "sre"', function(lines)
                    return oneline(play(lines, 36), 'ansible_user:%s*"sre"%s*$')
                end, 2, "^%s*ansible_user:"),
                code("decommissioned off", function(lines)
                    return oneline(play(lines, 36), "^%s*#+%s*decommissioned%-01:")
                end, 3, "decommissioned%-01:"),
                code("web01 -> 02 -> 03", function(lines)
                    return ordered_lines(play(lines, 36), {
                        "web01%.",
                        "web02%.",
                        "web03%.",
                    })
                end, 4, "web01%."),
            },
        },
        {
            id = 37,
            title = "Ansible Loop, When & Tags",
            goals = {
                code('when "RedHat"', function(lines)
                    return oneline(play(lines, 37), 'when:%s*ansible_os_family == "RedHat"%s*$')
                end, 1, "^%s*when:"),
                code("loop redosled", function(lines)
                    return ordered_lines(play(lines, 37), {
                        '"ca%-certificates"',
                        '"curl"',
                        '"jq"',
                        '"tmux"',
                    })
                end, 2, '"ca%-certificates"'),
                code("ftp off", function(lines)
                    return oneline(play(lines, 37), '^%s*#+%s*%-%s*"ftp"')
                end, 3, '"ftp"'),
                code('tags ["rhel9", "base"]', function(lines)
                    return oneline(play(lines, 37), 'tags:%s*%[%s*"rhel9"%s*,%s*"base"%s*%]%s*$')
                end, 4, "^%s*tags:"),
            },
        },
        {
            id = 38,
            title = "Ansible URI Healthcheck",
            goals = {
                code("https prod url", function(lines)
                    return oneline(play(lines, 38), 'url:%s*"https://api%.prod%.internal/health"%s*$')
                end, 1, "^%s*url:"),
                code("status_code: 200", function(lines)
                    return oneline(play(lines, 38), "^%s*status_code:%s*200%s*$")
                end, 2, "^%s*status_code:"),
                code("retries: 10", function(lines)
                    return oneline(play(lines, 38), "^%s*retries:%s*10%s*$")
                end, 3, "^%s*retries:"),
                code("delay: 5", function(lines)
                    return oneline(play(lines, 38), "^%s*delay:%s*5%s*$")
                end, 3, "^%s*delay:"),
                code("validate_certs: true", function(lines)
                    return oneline(play(lines, 38), "^%s*validate_certs:%s*true%s*$")
                end, 4, "^%s*validate_certs:"),
                code("ignore_tls_hack off", function(lines)
                    return oneline(play(lines, 38), "^%s*#+%s*ignore_tls_hack:%s*true")
                end, 4, "ignore_tls_hack:"),
            },
        },
        {
            id = 39,
            title = "Ansible Podman Rootless",
            goals = {
                code("podman_container", function(lines)
                    local text = play(lines, 39)
                    return oneline(text, "^%s*containers%.podman%.podman_container:%s*$")
                        and not oneline(text, "^%s*docker_container:%s*$")
                end, 1, "_container:"),
                code("agent:v2.1", function(lines)
                    return oneline(play(lines, 39), 'image:%s*"quay%.io/org/agent:v2%.1"%s*$')
                end, 2, "^%s*image:"),
                code("state: started", function(lines)
                    return oneline(play(lines, 39), "^%s*state:%s*started%s*$")
                end, 3, "^%s*state:"),
                code('restart "always"', function(lines)
                    return oneline(play(lines, 39), 'restart_policy:%s*"always"%s*$')
                end, 3, "^%s*restart_policy:"),
                code('ports ["8080:8080"]', function(lines)
                    return oneline(play(lines, 39), 'ports:%s*%[%s*"8080:8080"%s*%]%s*$')
                end, 4, "^%s*ports:"),
                code("privileged off", function(lines)
                    return oneline(play(lines, 39), "^%s*#+%s*privileged:%s*true")
                end, 4, "privileged:"),
            },
        },
        {
            id = 40,
            title = "Ansible HAProxy & Keepalived",
            goals = {
                code("10.50.0.10 svuda", function(lines)
                    local text = play(lines, 40)
                    return not text:find("old_vip_40", 1, true) and count_plain(text, "10.50.0.10") >= 2
                end, 1, "^%s*vip_address:"),
                code("priority: 150", function(lines)
                    return oneline(play(lines, 40), "^%s*priority:%s*150%s*$")
                end, 2, "^%s*priority:"),
                code('"MASTER"', function(lines)
                    return oneline(play(lines, 40), 'vrrp_state:%s*"MASTER"%s*$')
                end, 2, "^%s*vrrp_state:"),
                code("check_interval: 2", function(lines)
                    return oneline(play(lines, 40), "^%s*check_interval:%s*2%s*$")
                end, 2, "^%s*check_interval:"),
                code("nopreempt_bug off", function(lines)
                    return oneline(play(lines, 40), "^%s*#+%s*nopreempt_bug:%s*true")
                end, 3, "nopreempt_bug:"),
                code("haproxy pre keepalived", function(lines)
                    return ordered_lines(play(lines, 40), {
                        "name:%s*Configure haproxy",
                        "name:%s*Configure keepalived",
                    })
                end, 4, "name:%s*Configure haproxy"),
            },
        },
        {
            id = 41,
            title = "INCIDENT: CrashLoopBackOff",
            goals = {
                code('memory "1Gi"', function(lines)
                    return oneline(play(lines, 41), 'memory:%s*"1Gi"%s*$')
                end, 1, "^%s*memory:"),
                code('cpu "500m"', function(lines)
                    return oneline(play(lines, 41), 'cpu:%s*"500m"%s*$')
                end, 1, "^%s*cpu:"),
                code("initialDelay: 30", function(lines)
                    return oneline(play(lines, 41), "^%s*initialDelaySeconds:%s*30%s*$")
                end, 2, "^%s*initialDelaySeconds:"),
                code("period: 10", function(lines)
                    return oneline(play(lines, 41), "^%s*periodSeconds:%s*10%s*$")
                end, 2, "^%s*periodSeconds:"),
                code("failureThreshold: 5", function(lines)
                    return oneline(play(lines, 41), "^%s*failureThreshold:%s*5%s*$")
                end, 2, "^%s*failureThreshold:"),
                code("obrisi leak sim", function(lines)
                    return not play(lines, 41):find("memory_leak_sim_41", 1, true)
                end, 3, "memory_leak_sim_41:"),
                code("CRASH_ON_START off", function(lines)
                    return oneline(play(lines, 41), '^%s*#+%s*CRASH_ON_START:%s*"1"')
                end, 4, "CRASH_ON_START:"),
            },
        },
        {
            id = 42,
            title = "INCIDENT: CoreDNS Split-Brain",
            goals = {
                code("10.96.0.10 svuda", function(lines)
                    local text = play(lines, 42)
                    return not text:find("broken_dns_42", 1, true) and count_plain(text, "10.96.0.10") >= 2
                end, 1, "^%s*clusterIP:"),
                code("ndots: 2", function(lines)
                    return oneline(play(lines, 42), "^%s*ndots:%s*2%s*$")
                end, 2, "^%s*ndots:"),
                code("ClusterFirst", function(lines)
                    return oneline(play(lines, 42), "^%s*dnsPolicy:%s*ClusterFirst%s*$")
                end, 2, "^%s*dnsPolicy:"),
                code("replicas: 3", function(lines)
                    return oneline(play(lines, 42), "^%s*replicas:%s*3%s*$")
                end, 3, "^%s*replicas:"),
                code("loop_forward off", function(lines)
                    return oneline(play(lines, 42), '^%s*#+%s*loop_forward:%s*"127%.0%.0%.1"')
                end, 3, "loop_forward:"),
                code("upstream_1 prvi", function(lines)
                    return yaml_first_child(play(lines, 42), "^%s*upstreams:%s*$", "upstream_1:")
                end, 4, "^%s*upstream_1:"),
            },
        },
        {
            id = 43,
            title = "INCIDENT: Expired TLS Cert",
            goals = {
                code("letsencrypt-prod", function(lines)
                    return oneline(play(lines, 43), 'name:%s*"letsencrypt%-prod"%s*$')
                end, 1, "letsencrypt"),
                code('duration "2160h"', function(lines)
                    return oneline(play(lines, 43), 'duration:%s*"2160h"%s*$')
                end, 2, "^%s*duration:"),
                code('renewBefore "360h"', function(lines)
                    return oneline(play(lines, 43), 'renewBefore:%s*"360h"%s*$')
                end, 2, "^%s*renewBefore:"),
                code("shop.prod.example.com", function(lines)
                    return oneline(play(lines, 43), 'dnsName:%s*"shop%.prod%.example%.com"%s*$')
                end, 3, "^%s*dnsName:"),
                code("obrisi override", function(lines)
                    return not play(lines, 43):find("expired_override_43", 1, true)
                end, 4, "expired_override_43:"),
                code("selfSigned off", function(lines)
                    return oneline(play(lines, 43), "^%s*#+%s*selfSigned:%s*true")
                end, 4, "selfSigned:"),
            },
        },
        {
            id = 44,
            title = "INCIDENT: Unsafe Prod Playbook",
            goals = {
                code("serial: 2", function(lines)
                    return oneline(play(lines, 44), "^%s*serial:%s*2%s*$")
                end, 1, "^%s*serial:"),
                code("max_fail: 10", function(lines)
                    return oneline(play(lines, 44), "^%s*max_fail_percentage:%s*10%s*$")
                end, 1, "^%s*max_fail_percentage:"),
                code("any_errors_fatal", function(lines)
                    return oneline(play(lines, 44), "^%s*any_errors_fatal:%s*true%s*$")
                end, 1, "^%s*any_errors_fatal:"),
                code("force_reboot off", function(lines)
                    return oneline(play(lines, 44), "^%s*#+%s*force_reboot_all:%s*true")
                end, 2, "force_reboot_all:"),
                code("2x quorum check", function(lines)
                    local text = play(lines, 44)
                    return not text:find("TODO_CHECK", 1, true) and count_plain(text, '"Verify cluster quorum"') >= 3
                end, 3, "post_tasks:"),
                code("Backup pre Upgrade", function(lines)
                    return ordered_lines(play(lines, 44), {
                        "name:%s*Backup etcd",
                        "name:%s*Upgrade kubeadm",
                    })
                end, 4, "name:%s*Backup etcd"),
            },
        },
        {
            id = 45,
            title = "INCIDENT: K8s DiskPressure",
            goals = {
                code("imageGCHigh: 80", function(lines)
                    return oneline(play(lines, 45), "^%s*imageGCHighThresholdPercent:%s*80%s*$")
                end, 1, "^%s*imageGCHighThresholdPercent:"),
                code("imageGCLow: 60", function(lines)
                    return oneline(play(lines, 45), "^%s*imageGCLowThresholdPercent:%s*60%s*$")
                end, 1, "^%s*imageGCLowThresholdPercent:"),
                code('nodefs "10%"', function(lines)
                    return oneline(play(lines, 45), 'nodefs:%s*"10%%"%s*$')
                end, 2, "^%s*nodefs:"),
                code("keep_core_dumps off", function(lines)
                    return oneline(play(lines, 45), "^%s*#+%s*keep_core_dumps:%s*true")
                end, 3, "keep_core_dumps:"),
                code("logging indent (4/6 sp)", function(lines)
                    local text = play(lines, 45)
                    return oneline(text, "^    logging:%s*$") and oneline(text, '^      maxSize:%s*"100Mi"%s*$')
                end, 4, "logging:"),
            },
        },
        {
            id = 46,
            title = "BOSS 3: Multi-Container Mesh",
            goals = {
                code("prod_mesh svuda", function(lines)
                    local text = play(lines, 46)
                    return not text:find("beta_mesh_46", 1, true) and count_plain(text, "prod_mesh") >= 3
                end, 1, "^%s*namespace:"),
                code("replicas: 4", function(lines)
                    return oneline(play(lines, 46), "^%s*replicas:%s*4%s*$")
                end, 2, "^%s*replicas:"),
                code("runAsNonRoot: true", function(lines)
                    return oneline(play(lines, 46), "^%s*runAsNonRoot:%s*true%s*$")
                end, 2, "^%s*runAsNonRoot:"),
                code("envoy:v1.31", function(lines)
                    return oneline(play(lines, 46), 'image:%s*"envoyproxy/envoy:v1%.31"%s*$')
                end, 3, "^%s*image:"),
                code("port 15001", function(lines)
                    return oneline(play(lines, 46), "^%s*%-%s*containerPort:%s*15001%s*$")
                end, 3, "containerPort:"),
                code("ENVOY_LOG off", function(lines)
                    return oneline(play(lines, 46), '^%s*#+%s*ENVOY_LOG_LEVEL:%s*"trace"')
                end, 4, "ENVOY_LOG_LEVEL:"),
                code("obrisi sidecar_junk", function(lines)
                    return not play(lines, 46):find("sidecar_junk_46", 1, true)
                end, 4, "sidecar_junk_46:"),
                code("init -> app -> envoy", function(lines)
                    return ordered_lines(play(lines, 46), {
                        '"init%-config"',
                        '"app"',
                        '"envoy%-sidecar"',
                    })
                end, 5, '"init%-config"'),
            },
        },
        {
            id = 47,
            title = "BOSS 4: Ansible RHEL 9 Role",
            goals = {
                code("rhel9_prod + become + serial", function(lines)
                    local text = play(lines, 47)
                    return oneline(text, "^%s*hosts:%s*rhel9_prod%s*$")
                        and oneline(text, "^%s*become:%s*true%s*$")
                        and oneline(text, "^%s*serial:%s*1%s*$")
                end, 1, "^%s*hosts:"),
                code("enforcing", function(lines)
                    return oneline(play(lines, 47), "^%s*selinux_state:%s*enforcing%s*$")
                end, 1, "^%s*selinux_state:"),
                code("dnf + systemd FQCN", function(lines)
                    local text = play(lines, 47)
                    return oneline(text, "^%s*ansible%.builtin%.dnf:%s*$")
                        and oneline(text, "^%s*ansible%.builtin%.systemd:%s*$")
                        and not oneline(text, "^%s*yum:%s*$")
                        and not oneline(text, "^%s*service:%s*$")
                end, 2, "Install packages"),
                code("obrisi legacy_hack", function(lines)
                    return not play(lines, 47):find("legacy_hack_47", 1, true)
                end, 3, "legacy_hack_47:"),
                code("disable_firewall off", function(lines)
                    return oneline(play(lines, 47), "^%s*#+%s*disable_firewall:%s*true")
                end, 3, "disable_firewall:"),
                code("2x notify Reload nginx", function(lines)
                    local text = play(lines, 47)
                    return not text:find('"TODO"', 1, true) and count_plain(text, 'notify: "Reload nginx"') >= 2
                end, 4, "Ensure service started"),
                code("phases 1..4", function(lines)
                    return yaml_list_slot(play(lines, 47), "^%s*phases:%s*$", 1, "1. Firewall")
                        and yaml_list_slot(play(lines, 47), "^%s*phases:%s*$", 2, "2. Packages")
                        and yaml_list_slot(play(lines, 47), "^%s*phases:%s*$", 3, "3. Config")
                        and yaml_list_slot(play(lines, 47), "^%s*phases:%s*$", 4, "4. Start")
                end, 5, "^%s*phases:"),
            },
        },
        {
            id = 48,
            title = "BOSS 5: Zero-Trust Namespace",
            goals = {
                code("zero_trust_prod svuda", function(lines)
                    local text = play(lines, 48)
                    return not text:find("open_ns_48", 1, true) and count_plain(text, "zero_trust_prod") >= 3
                end, 1, "^%s*namespace:"),
                code('pods "50"', function(lines)
                    return oneline(play(lines, 48), 'pods:%s*"50"%s*$')
                end, 2, "^%s*pods:"),
                code('memory "32Gi"', function(lines)
                    return oneline(play(lines, 48), 'memory:%s*"32Gi"%s*$')
                end, 2, "^%s*memory:"),
                code('cpu "200m"', function(lines)
                    return oneline(play(lines, 48), 'default_cpu:%s*"200m"%s*$')
                end, 2, "^%s*default_cpu:"),
                code("Egress on", function(lines)
                    return oneline(play(lines, 48), "^%s*%-%s*Egress%s*$")
                end, 3, "Egress"),
                code('"TCP" + 5432', function(lines)
                    local text = play(lines, 48)
                    return oneline(text, 'protocol:%s*"TCP"%s*$') and oneline(text, "^%s*port:%s*5432%s*$")
                end, 3, "^%s*port:"),
                code("allow_all off", function(lines)
                    return oneline(play(lines, 48), "^%s*#+%s*allow_all_internet:%s*true")
                end, 4, "allow_all_internet:"),
                code("obrisi bypass", function(lines)
                    return not play(lines, 48):find("quota_bypass_48", 1, true)
                end, 4, "quota_bypass_48:"),
            },
        },
        {
            id = 49,
            title = "BOSS 6: DR Failover Pack",
            goals = {
                code("dr_frankfurt svuda", function(lines)
                    local text = play(lines, 49)
                    return not text:find("dr_old_49", 1, true) and count_plain(text, "dr_frankfurt") >= 3
                end, 1, "^%s*region:"),
                code("replicas 6 / weight 100 / serial 1", function(lines)
                    local text = play(lines, 49)
                    return oneline(text, "^%s*replicas:%s*6%s*$")
                        and oneline(text, "^%s*weight:%s*100%s*$")
                        and oneline(text, "^%s*serial:%s*1%s*$")
                end, 2, "^%s*replicas:"),
                code("reencrypt + certs", function(lines)
                    local text = play(lines, 49)
                    return oneline(text, "^%s*termination:%s*reencrypt%s*$")
                        and oneline(text, "^%s*validate_certs:%s*true%s*$")
                end, 3, "^%s*termination:"),
                code("skip_backup off", function(lines)
                    return oneline(play(lines, 49), "^%s*#+%s*skip_backup_verify:%s*true")
                end, 4, "skip_backup_verify:"),
                code("obrisi dr_junk", function(lines)
                    return not play(lines, 49):find("dr_test_junk_49", 1, true)
                end, 4, "dr_test_junk_49:"),
                code("dr_steps 1..4", function(lines)
                    return yaml_list_slot(play(lines, 49), "^%s*dr_steps:%s*$", 1, "1. Freeze writes")
                        and yaml_list_slot(play(lines, 49), "^%s*dr_steps:%s*$", 2, "2. Promote replica")
                        and yaml_list_slot(play(lines, 49), "^%s*dr_steps:%s*$", 3, "3. Switch DNS")
                        and yaml_list_slot(play(lines, 49), "^%s*dr_steps:%s*$", 4, "4. Resume traffic")
                end, 5, "^%s*dr_steps:"),
            },
        },
        {
            id = 50,
            title = "FINAL GRAND MASTER BOSS",
            goals = {
                code("obrisi trash", function(lines)
                    return not play(lines, 50):find("cutover_trash_50", 1, true)
                end, 1, "cutover_trash_50:"),
                code("prod_v5 svuda (4x)", function(lines)
                    local text = play(lines, 50)
                    return not text:find("rc_alpha_50", 1, true) and count_plain(text, "prod_v5") >= 4
                end, 2, "^%s*image:"),
                code("replicas: 8", function(lines)
                    return oneline(play(lines, 50), "^%s*replicas:%s*8%s*$")
                end, 3, "^%s*replicas:"),
                code("serial: 1", function(lines)
                    return oneline(play(lines, 50), "^%s*serial:%s*1%s*$")
                end, 3, "^%s*serial:"),
                code("surround (region/tag/port)", function(lines)
                    local text = play(lines, 50)
                    return oneline(text, 'region:%s*"eu%-central%-1"%s*$')
                        and oneline(text, 'release_tag:%s*"v5%.0%.0"%s*$')
                        and oneline(text, "^%s*port:%s*8443%s*$")
                end, 4, "^%s*port:"),
                code("become + runAsNonRoot", function(lines)
                    local text = play(lines, 50)
                    return oneline(text, "^%s*become:%s*true%s*$") and oneline(text, "^%s*runAsNonRoot:%s*true%s*$")
                end, 5, "^%s*runAsNonRoot:"),
                code("chaos & DEBUG off", function(lines)
                    local text = play(lines, 50)
                    return oneline(text, "^%s*#+%s*chaos_mode:%s*true")
                        and oneline(text, '^%s*#+%s*DEBUG_TRACE:%s*"1"')
                end, 5, "chaos_mode:"),
                code("cutover_plan 1..4", function(lines)
                    return yaml_list_slot(play(lines, 50), "^%s*cutover_plan:%s*$", 1, "1. Preflight check")
                        and yaml_list_slot(play(lines, 50), "^%s*cutover_plan:%s*$", 2, "2. DB migration")
                        and yaml_list_slot(play(lines, 50), "^%s*cutover_plan:%s*$", 3, "3. Canary rollout")
                        and yaml_list_slot(play(lines, 50), "^%s*cutover_plan:%s*$", 4, "4. Full cutover")
                end, 6, "^%s*cutover_plan:"),
                code("2x Notify SRE Slack", function(lines)
                    local text = play(lines, 50)
                    return not text:find("FIXME", 1, true)
                        and oneline(text, 'pre_notify:%s*"Notify SRE Slack"%s*$')
                        and oneline(text, 'post_notify:%s*"Notify SRE Slack"%s*$')
                end, 7, "^%s*post_notify:"),
            },
        },
    }
end

return build_levels
