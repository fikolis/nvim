# Tune test (post-fix verification)

Headless Neovim `0.12.6`, verified against fixtures under `/tmp/nvim-ft-test` plus `.hcl` and Ansible lint checks.

| Fixture | Filetype | Indent | Treesitter | LSP | Formatter | `nvim-lint` |
|---|---|---|---|---|---|---|
| `platform-ansible/site.yml` | `yaml.ansible` | 2 | yes | `ansiblels` (`root=platform-ansible`) | `yamlfmt` | *(handled by `ansiblels`)* |
| `platform-ansible/k8s/deploy.yml` | `yaml.kubernetes` | 2 | yes | `yamlls` (K8s schema) | `yamlfmt` | `yamllint` |
| `infra/site.yml` | `yaml.ansible` | 2 | yes | `ansiblels` (`root=infra`) | `yamlfmt` | *(handled by `ansiblels`)* |
| `infra/roles/web/tasks/main.yml` | `yaml.ansible` | 2 | yes | `ansiblels` (`root=infra`) | `yamlfmt` | *(handled by `ansiblels`)* |
| `infra/group_vars/all.yml` | `yaml.ansible` | 2 | yes | `ansiblels` (`root=infra`) | `yamlfmt` | *(handled by `ansiblels`)* |
| `sysprep/orphan.yml` | `yaml.ansible` | 2 | yes | `ansiblels` (`root=nil`) | `yamlfmt` | *(handled by `ansiblels`)* |
| `sysprep/k8s/app.yml` | `yaml.kubernetes` | 2 | yes | `yamlls` (K8s schema) | `yamlfmt` | `yamllint` |
| `sysprep/templates/app.yml.j2` | `yaml.jinja` | 2 | yes | none | none | none |
| `k8s/app.yml` | `yaml.kubernetes` | 2 | yes | `yamlls` (K8s schema) | `yamlfmt` | `yamllint` |
| `kubernetes/app.yml` | `yaml.kubernetes` | 2 | yes | `yamlls` (K8s schema) | `yamlfmt` | `yamllint` |
| `ocp/app.yaml` | `yaml.kubernetes` | 2 | yes | `yamlls` (K8s schema) | `yamlfmt` | `yamllint` |
| `plain/config.yml` | `yaml` | 2 | yes | `yamlls` | `yamlfmt` | `yamllint` |
| `*.hcl` | `hcl` | 2 | yes | `terraformls` | `terraform_fmt` | none |

## Key fixes verified

- **Kubernetes LSP & schema:** `yamlls` now attaches to `yaml.kubernetes` with Kubernetes schema hover/validation/completion enabled.
- **Deterministic precedence:** `yaml.kubernetes` (`priority = 10`) always wins over `yaml.ansible` (`priority = 5` / `1`), including `platform-ansible/k8s/deploy.yml` and `sysprep/k8s/app.yml`.
- **Standard Ansible repos (`infra/`):** detected via `ansible.cfg` / `.ansible-lint` root markers and standard role/vars/playbook paths.
- **Ansible Python & `ansible-lint`:** `ansiblels` resolves the working Python interpreter from `ansible`'s shebang (or `python3`) and skips broken venv binaries on `PATH` (such as a stale Mason `ansible-lint`), reporting diagnostics cleanly (`no-changed-when` verified) without duplicating `nvim-lint`.
- **Jinja YAML templates (`.yml.j2`):** mapped to `yaml.jinja` with 2-space indent and Treesitter highlighting, excluded from `yamlls`, `yamlfmt`, and `yamllint`.
- **HCL:** `terraformls` now attaches to `hcl` in addition to `terraform` and `terraform-vars`.
