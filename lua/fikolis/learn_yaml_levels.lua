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
    }
end

return build_levels
