-- Explained step-by-step solutions and Vim grammar patterns for all 83 Dojo levels:
--   core    (1..33) — learning/learn_nvim.lua
--   k8s     (1..25) — learning/k8s/learn_k8s.yaml
--   ansible (1..25) — learning/ansible/learn_ansible.yaml

local M = {}

-- ============================================================================
-- CORE LUA DOJO (33 NIVOA)
-- ============================================================================
M.core = {
    [1] = {
        patterns = { "<leader>?" },
        steps = {
            "Pritisni `<Space>?` -> otvara Snacks Keymap pretragu. Kucaj `harpoon` da vidis sve Harpoon precice, pa `<Esc>`.",
            "Pritisni `<Space>wk` -> otvara Which-Key meni svih globalnih grupa precica.",
            "Pritisni `<Space>w?` -> prikazuje samo lokalne (buffer) precice za ovaj fajl.",
        },
        tip = "Ne moras nista da pamtis napamet — `<Space>?` je tvoj ugradjeni Google za svaku precicu u configu.",
    },
    [2] = {
        patterns = { "<C-d/u>" },
        steps = {
            "Pritisni `<C-d>` (pola ekrana dole) pa `<C-u>` (pola ekrana gore) — tvoj config dodaje `zz` pa kursor uvek ostaje u centru.",
            "Ukucaj `/PING_META` pa `<Enter>` da pronadjes prvu metu.",
            "Pritisni `n` (Next) da skocis na `PING_META_2` i `PING_META_3`, pa `N` (Previous) za nazad — svaki put centrirano!",
        },
        tip = "U Vimu veliko slovo cesto znaci SUPROTAN smer: `n` napred / `N` nazad, `f` napred / `F` nazad.",
    },
    [3] = {
        patterns = { "J" },
        steps = {
            "Stani bilo gde na liniju `local nivo_03_cmd = \"kubectl\"`.",
            "Pritisni `J` (Join) tri puta zaredom -> svaka donja linija se spaja u trenutnu sa jednim razmakom.",
            "Primeti da tvoj remap (`mzJ`z`) cuva poziciju kursora na pocetku linije umesto da bezi na kraj!",
        },
        tip = "`J` znaci Join — spaja sledecu liniju sa trenutnom bez ulaska u Insert mod.",
    },
    [4] = {
        patterns = { "V+JK" },
        steps = {
            "Stani na `\"1. git pull\"`, pritisni `V` (Visual Line) pa `K` jednom da je popnes na vrh (iznad 3).",
            "Stani na `\"2. docker build\"`, pritisni `V` pa `K` dva puta da dodje odmah ispod 1.",
            "Stani na `\"5. healthcheck\"`, pritisni `V` pa `J` jednom da sidje na poslednje mesto ispod 4.",
        },
        tip = "`V` (Visual Line) + `J`/`K` pomera cele linije ili citave blokove gore/dole kao u IDE-u, ali brze.",
    },
    [5] = {
        patterns = { 'ci"', "ci'", "<C-c>" },
        steps = {
            'Stani bilo gde na liniju `nivo_05_status = "BROKEN"` i ukucaj `ci"` (Change Inside `" "`) -> brise BROKEN i ulazi u Insert.',
            "Ukucaj `HEALTHY` pa izadji sa `<C-c>` (brza zamena za `<Esc>`).",
            'Sidji na sledecu liniju (`j`), ukucaj `ci"`, kucaj `v1.0.0`, pa `<C-c>`.',
        },
        tip = "Ne moras ni da budes unutar navodnika! `ci\"` automatski skace u prve navodnike u toj liniji. Isto radi i `ci'` za `' '`!",
    },
    [6] = {
        patterns = { 'yi"', 'vi"', "<leader>p" },
        steps = {
            'Stani na liniju `nivo_06_good_port = "8443"` i ukucaj `yi"` (Yank Inside `" "`) — kopirao si samo `8443`.',
            'Sidji na `api = "8080"` i ukucaj `vi"<Space>p` (Visual Inside `" "` pa Void Paste) -> postaje `"8443"`, a u registru i dalje ostaje `8443`!',
            'Sidji na `auth = "9000"` (`j`) -> `vi"<Space>p`, pa na `metrics = "3000"` (`j`) -> `vi"<Space>p`.',
        },
        tip = "Obicno `p` u Visual modu pregazi tvoj yank onim sto si obrisao. `<Space>p` ga baca u crnu rupu pa mozes lepiti beskonacno puta!",
    },
    [7] = {
        patterns = { "yiw", "<leader>dd", "viw", "<leader>p" },
        steps = {
            "Stani na rec `prod_secret_key` i ukucaj `yiw` (Yank Inside Word) -> kopirana je cela rec.",
            "Sidji na `local nivo_07_junk = \"OBRISI_ME\"` i obrisi je sa `<Space>dd` (Void Delete) — obican `dd` bi ti pregazio kopiranu rec!",
            "Na liniji `FIXME`, stani na `FIXME` i ukucaj `viw<Space>p` (Visual Inside Word + Void Paste) -> postaje `prod_secret_key`.",
        },
        tip = "Kad god nosis nesto vazno u yanku a moras nesto da obrises usput, koristi `<Space>d` ili `<Space>dd` (crna rupa).",
    },
    [8] = {
        patterns = { "<leader>y", 'vi"' },
        steps = {
            "Stani bilo gde na liniju `local nivo_08_url = ...` i pritisni `<Space>Y` (kopira celu liniju u sistemski clipboard).",
            'Ostani na istoj liniji, ukucaj `vi"` (Visual Inside `" "`) da selektujes samo URL, pa pritisni `<Space>y`.',
        },
        tip = "Obican `y` ostaje unutar Neovima. `<Space>y` / `<Space>Y` salje u macOS/sistemski clipboard za Cmd+V van editora.",
    },
    [9] = {
        patterns = { "<leader>s" },
        steps = {
            "Stani na bilo koju pojavu reci `stari_klaster_09`.",
            "Pritisni `<Space>s` -> komandna linija se sama popunjava sa `:%s/\\<stari_klaster_09\\>/stari_klaster_09/gI` i kursor stoji na zameni.",
            "Ukucaj `novi_klaster_09` i pritisni `<Enter>` -> sve 4 pojave se menjaju odjednom!",
        },
        tip = "`<Space>s` je tvoja najbrza masovna zamena reci u fajlu bez rucnog kucanja regexa.",
    },
    [10] = {
        patterns = { "gcc", "V2jgc" },
        steps = {
            "Stani na liniju `debug = true,` i ukucaj `gcc` -> linija postaje `-- debug = true,`.",
            "Sidji na `-- tls_enabled = true,` (`j`), pritisni `V2j` (selektuje tu i jos 2 linije dole), pa ukucaj `gc` -> sve 3 linije se otkomentarisu odjednom!",
        },
        tip = "`gc` je glagol Comment: `gcc` = jedna linija, `V2jgc` ili `gc2j` = blok linija.",
    },
    [11] = {
        patterns = { 'ysiw"', "ysiw'", "ys3w)", "yss)" },
        steps = {
            'Na `local nivo_11_region = eu_west`, stani na `eu_west` i ukucaj `ysiw"` (You Surround Inside Word `"`) -> `"eu_west"`.',
            "Na `local nivo_11_name = my_app`, stani na `my_app` i ukucaj `ysiw'` -> `'my_app'`.",
            "Na `local nivo_11_sum = x + y * 2`, stani na `x` i ukucaj `ys3w)` (You Surround 3 words `)`) -> `(x + y) * 2`.",
        },
        tip = "Surround prati istu Vim gramatiku: `ys` (dodaj) + motion/textobject (`iw`, `3w`) + znak (`\"`, `'`, `)`). Zatvorena zagrada `)` = bez razmaka!",
    },
    [12] = {
        patterns = { "cs'\"", "cs\"'", "cs)}" },
        steps = {
            "Stani unutar `'ansible'` i ukucaj `cs'\"` (Change Surround `'` u `\"`) -> `\"ansible\"`.",
            "Stani unutar `\"terraform\"` i ukucaj `cs\"'` (Change Surround `\"` u `'`) -> `'terraform'`.",
            "Stani unutar `(\"packer\")` i ukucaj `cs)}` (Change Surround `()` u `{}`) -> `{\"packer\"}`.",
        },
        tip = "`cs` cita se kao: Change Surround [STARI znak] -> [NOVI znak]. Primer: `cs'\"` menja `'` u `\"`.",
    },
    [13] = {
        patterns = { "ds)", 'ds"' },
        steps = {
            "Stani unutar `(42)` i ukucaj `ds)` (Delete Surround `)`) -> ostaje cist broj `42`.",
            "Stani unutar `((100))` i ukucaj `ds)` pa jos jednom `ds)` (ili `.`!) -> skida oba sloja zagrada -> `100`.",
            'Stani unutar `"true"` i ukucaj `ds"` (Delete Surround `"`) -> ostaje boolean `true`.',
        },
        tip = "`ds` = Delete Surround (obrisi okruzeno). Skida SAMO okvir, a tekst unutra ostaje netaknut!",
    },
    [14] = {
        patterns = { "ds)", 'ysiw"', "cs'\"" },
        steps = {
            'Na `name = (host_name),` stani na `host_name` -> `ds)` skida zagrade, pa `ysiw"` dodaje navodnike -> `"host_name"` (ili jednim potezom `cs)"`!).',
            "Na `role = 'worker',` stani u string -> `cs'\"` menja u `\"worker\"`.",
            'Na `env = ("prod"),` stani u string -> `ds)` skida spoljne zagrade -> `"prod"`.',
        },
        tip = "Pro trik: umesto `ds)` pa `ysiw\"`, mozes direktno `cs)\"` (Change Surround `)` u `\"`)!",
    },
    [15] = {
        patterns = { "]f" },
        steps = {
            "Stani na `local function nivo_15_alpha()`.",
            "Pritisni `]f` (Next Function) tri puta da skocis redom na `beta`, `gamma` (tu je `TAJNA_SIFRA`) i `delta`.",
            "Pritisni `[f` (Previous Function) da se vratis nazad.",
        },
        tip = "`]` uvek ide NAPRED, `[` uvek ide NAZAD: `]f`/`[f` funkcije, `]d`/`[d` greske, `]h`/`[h` git izmene.",
    },
    [16] = {
        patterns = { "cif" },
        steps = {
            "Stani bilo gde unutar funkcije `nivo_16_bloated` (npr. na `local tmp1`).",
            "Ukucaj `cif` (Change Inside Function) -> Treesitter brise SVE 4 linije tela funkcije i ulazi u Insert mod, dok potpis i `end` ostaju!",
            "Ukucaj `return a + b` i izadji sa `<C-c>`.",
        },
        tip = "`i` = Inside, `f` = Function. Ista gramatika kao `ci\"` ili `ciw`, samo nad celim telom funkcije zahvaljujuci Treesitter-u!",
    },
    [17] = {
        patterns = { "daf" },
        steps = {
            "Stani bilo gde unutar funkcije `nivo_17_deprecated`.",
            "Ukucaj `daf` (Delete Around Function) -> cela funkcija od `local function` do `end` nestaje u jednom potezu!",
        },
        tip = "Uporedi: `dif` brise SAMO telo (Inside), a `daf` brise CELU funkciju sa potpisom i `end` (Around)!",
    },
    [18] = {
        patterns = { "daa", "cia" },
        steps = {
            "U `nivo_18_deploy(env, unused_flag, replicas)` stani na `unused_flag` i ukucaj `daa` (Delete Around Argument) -> brise i zarez!",
            'U `nivo_18_call()` stani na `"staging"`, ukucaj `cia` (Change Inside Argument), ukucaj `"prod"`, pa `<C-c>`.',
            "Stani na `false` u istom pozivu i ukucaj `daa` -> ostaje cisto `nivo_18_deploy(\"prod\", 3)`.",
        },
        tip = "Zasto `daa` (Around) a ne `dia` (Inside)? Zato sto `a` (Around) hvata i zarez oko argumenta, pa ne ostaje visak zareza!",
    },
    [19] = {
        patterns = { "vaf", "V+JK" },
        steps = {
            "Stani bilo gde u `nivo_19_first` (donja funkcija).",
            "Ukucaj `vaf` (Visual Around Function) -> selektuje celu funkciju od `local function` do `end`.",
            "Pritisni `K` nekoliko puta dok `nivo_19_first` ne dodje IZNAD `nivo_19_second`, pa `<Esc>`.",
        },
        tip = "Kombinovanje objekata i akcija je prava snaga Vima: `vaf` selektuje bilo koju funkciju ma koliko linija imala, a `J`/`K` je seli!",
    },
    [20] = {
        patterns = { "picker" },
        steps = {
            "Pritisni `<Space>pf` (Find Files), kucaj `ai.lua` i otvori ga sa `<Enter>`.",
            "Pritisni `<Space>pb` (Buffers) i izaberi `learn_nvim.lua` da se vratis.",
            "Pritisni `<C-p>` (Git Files) pa `<Esc>`, a zatim `<Space>vh` (Help), kucaj `undotree` pa `<Esc>`.",
        },
        tip = "Prefix `<Space>p` je tvoj Project/Picker hub: `pf` fajlovi, `pb` baferi, `ps` grep, `pd` dijagnostika.",
    },
    [21] = {
        patterns = { "grep" },
        steps = {
            'Stani na rec `"Snacks"` i pritisni `<Space>pws` (Project Word Search) -> trazi tu rec svuda u configu, pa `<Esc>`.',
            'Stani na `"k8s-prod-eu-west-1"` i pritisni `<Space>pWs` (veliko `W` = cela WORD sa crticama!), pa `<Esc>`.',
            "Pritisni `<Space>ps` (Live Grep), kucaj `terminal`, pa `<Esc>`.",
        },
        tip = "Malo `w` staje na crticama (`k8s`), veliko `W` hvata sve do razmaka (`k8s-prod-eu-west-1`).",
    },
    [22] = {
        patterns = { "oil" },
        steps = {
            "Pritisni `-` -> otvara Oil u folderu `learning/`. Pritisni jos jednom `-` da se popnes u `~/.config/nvim/`.",
            "Sidji na `lua/` (`j`) -> `<Enter>`, pa `fikolis/` -> `<Enter>`, pa `lazy/` -> `<Enter>`.",
            "Vrati se nazad na `learn_nvim.lua` sa `<C-o>` (ili navigacijom kroz Oil i `<Enter>` na fajlu).",
        },
        tip = "U Oil-u je `-` uvek 'nivo gore', `<Enter>` je 'udji/otvori', a fajlove mozes brisati/preimenovati kao obican tekst!",
    },
    [23] = {
        patterns = { "harpoon" },
        steps = {
            "Dok si u `learn_nvim.lua`, pritisni `<Space>a` (Add) da ga pinujes kao fajl #1.",
            "Otvori `lua/fikolis/remap.lua` (`<Space>pf`) -> `<Space>a` (#2), pa `lua/fikolis/ai.lua` -> `<Space>a` (#3).",
            "Pritisni `<C-e>` za pregled liste (`q` za izlaz), pa isprobaj instant skokove: `<C-j>` (#1), `<C-k>` (#2), `<C-h>` (#3).",
        },
        tip = "Harpoon eliminise tabove: za 3-4 fajla na kojima radis celog dana, `<C-j/k/h/l>` je brze od bilo kog menija.",
    },
    [24] = {
        patterns = { "zen_undo", 'ci"' },
        steps = {
            "Isprobaj `<Space>zz` (Zen Mode) pa opet `<Space>zz` za izlaz; isto za `<Space>zZ`.",
            'Na `nivo_24_history = "PRVA"` uradi `ci"` -> `DRUGA` -> `<C-c>`, pa `u` (undo nazad na PRVA), pa `ci"` -> `TRECA` -> `<C-c>`.',
            "Pritisni `<Space>u` (Undotree), kreci se gore/dole po granama stabla dok ne vratis `\"DRUGA\"`, pa zatvori Undotree.",
        },
        tip = "Neovim nikad ne gubi undo grane kad uradis `u` pa novu izmenu — `<Space>u` ti pokazuje CELO stablo vremena!",
    },
    [25] = {
        patterns = { "lsp_nav" },
        steps = {
            "Stani na `nivo_25_calc_replicas` unutar funkcije `nivo_25_usage`.",
            "Pritisni `K` (Hover dokumentacija), pa `gd` (Go to Definition) — vrati se sa `<C-o>`.",
            "Pritisni `<Space>vrr` (References) i `<Space>vws` (Workspace Symbols).",
        },
        tip = "Kad god skocis negde sa `gd`, `<C-o>` (Jump Out / nazad) te vraca tacno tamo gde si bio!",
    },
    [26] = {
        patterns = { "lsp_rename" },
        steps = {
            "Stani na `stari_brojac` i pritisni `<Space>vrn` (LSP Rename) -> ukucaj `novi_brojac` + `<Enter>` (menja sve 3 pojave inteligentno!).",
            "U Insert modu kucaj `nivo_25_`, listaj sa `<C-n>`/`<C-p>` i potvrdi sa `<C-y>` (mozes potom obrisati test liniju).",
            "Unutar zagrada poziva funkcije u Insert modu pritisni `<C-h>` za Signature Help.",
        },
        tip = "`<Space>vrn` je pametniji od search/replace — menja samo tu promenljivu u tom scope-u po LSP AST-u!",
    },
    [27] = {
        patterns = { "diag" },
        steps = {
            "Pritisni `]d` (Next Diagnostic) da skocis direktno na `unused_var`.",
            "Pritisni `<Space>vd` (Diagnostic Float) da procitas poruku greske.",
            "Otvori i zatvori Trouble bafer (`<Space>qb`), Trouble simbole (`<Space>qs`), Snacks dijagnostiku (`<Space>pd`) i Code Actions (`<Space>vca`).",
        },
        tip = "`]d` / `[d` te vodi pravo na greske bez citanja celog fajla, a `<Space>vca` cesto nudi automatsku popravku.",
    },
    [28] = {
        patterns = { "format" },
        steps = {
            "Stani bilo gde unutar neuredne funkcije `nivo_28_messy`.",
            "Ukucaj `vaf` (Visual Around Function) da selektujes celu funkciju.",
            "Pritisni `<Space>f` -> Conform pokrece `stylua` i savrseno formatira samo tu funkciju!",
        },
        tip = "`vaf<Space>f` je zlatni combo kad radis u tudjem fajlu i zelis da formatiras SAMO funkciju koju si dirao.",
    },
    [29] = {
        patterns = { "git" },
        steps = {
            "Izmeni tekst u `nivo_29_git_line`, pa pritisni `<Space>ghp` (Git Hunk Preview) da vidis diff u floatu.",
            "Skaci po izmenama sa `]h` / `[h`, pa vrati izmenu nazad jednim klikom: `<Space>ghr` (Reset Hunk).",
            "Otvori Lazygit (`<Space>gl`, izlaz `q`) i Fugitive (`<Space>gs`, izlaz `q`).",
        },
        tip = "`<Space>gh*` je tvoja Git Hunk familija: `p` preview, `s` stage, `r` reset, `b` blame.",
    },
    [30] = {
        patterns = { "ai" },
        steps = {
            "Pritisni `<Space>ca` (ili `cg`/`co`/`cx`) da otvoris AI CLI floating terminal.",
            "Pritisni `<C-q>` da sakrijes prozor — proces i razgovor ostaju zivi u pozadini!",
            "Pritisni ponovo isti shortcut (`<Space>ca`) da se instant vratis u istu sesiju.",
        },
        tip = "`<C-q>` ne ubija terminal nego ga minimizuje — savrseno za brz skok izmedju koda i AI asistenta.",
    },
    [31] = {
        patterns = { "gcc", "V+JK", "ds)", "cs'\"", 'yi"', "<leader>p" },
        steps = {
            "Na `legacy = true,` -> `gcc` (zakomentarisi).",
            "Na `name = \"payments-api\",` -> `V` pa `KK` (popni na 1. mesto u tabeli).",
            "Na `port = (8080),` -> `ds)` (skini zagrade). Na `region = 'eu-central-1',` -> `cs'\"`.",
            'Na `local nivo_31_env = "production"` -> `yi"`, pa na `primary_env` i `fallback_env` po `vi"<Space>p`!',
        },
        tip = "Svaki korak ovog Bossa je samo 2-3 tastera jer kombinujes `gcc`, `V+K`, `ds)`, `cs'\"` i `yi\" + vi\"<Space>p`.",
    },
    [32] = {
        patterns = { "]f", "daa", "ds)", "cia", "format" },
        steps = {
            "Skoci na `nivo_32_build` sa `]f`, stani na `dead_arg` -> `daa` (obrisi argument + zarez).",
            "Na `return (target) ...` stani na `target` -> `ds)` (skini zagrade).",
            'U `nivo_32_runner`: stani na `true` -> `daa`, stani na `\'debug\'` -> `cia` pa ukucaj `"release"` + `<C-c>`.',
            "Vrati se u `nivo_32_build` (`[f`) i sredi format sa `vaf<Space>f`!",
        },
        tip = "Treesitter + Surround + Conform = hirursko refaktorisanje bez ijednog rucnog brisanja zareza ili razmaka!",
    },
    [33] = {
        patterns = { "daf", "lsp_rename", 'yi"', "<leader>dd", "<leader>p", "cs'\"", "ds)", "gcc", "V+JK", "format" },
        steps = {
            "Stani u `nivo_33_trash` -> `daf` (obrisi celu funkciju u 1 potezu).",
            "U `nivo_33_deploy_cluster`, stani na `x_cfg` -> `<Space>vrn` -> `cluster_cfg` + `<Enter>`.",
            'Na `nivo_33_latest = "v2.5.0"` -> `yi"`. Obrisi `temp_junk = 999` sa `<Space>dd` (cuva yank!). Zameni `"v0.1.0"` sa `vi"<Space>p`.',
            "Na `'k8s'` -> `cs'\"`; na `(3)` -> `ds)`; na `dry_run = true` -> `gcc`; na `version = ...` -> `V` + `KKK` na vrh tabele.",
            "Formatiraj celu funkciju sa `vaf<Space>f` i baci pogled na istoriju sa `<Space>u`!",
        },
        tip = "Cestitam! Ako ovo radis tecno, koristis 100% Vim gramatike — prsti misle u glagolima i objektima, ne u strelicama!",
    },
}

-- ============================================================================
-- KUBERNETES & OPENSHIFT DOJO (25 NIVOA)
-- ============================================================================
M.k8s = {
    [1] = {
        patterns = { "<leader>+", "f5r7", "ciw", "cmp" },
        steps = {
            "Stani na liniju `replicas: 1` i ukucaj `2<Space>+` -> broj skace na `3` (tmux-safe zamena za `<C-a>`!).",
            'Na `image: "nginx:1.25"` ukucaj `f5` (Find `5`) pa `r7` (Replace sa `7`) -> `"nginx:1.27"` bez Insert moda!',
            "Na `imagePullPolicy: Always` stani na `Always`, ukucaj `ciw` (Change Inside Word), kucaj `IfNot`, potvrdi iz K8s autocomplete-a sa `<C-y>` -> `IfNotPresent`.",
        },
        tip = "Tri najcesce DevOps izmene: `<broj><Space>+` za brojeve, `f<c>r<x>` za 1 cifru u tagu, `ciw` + `<C-y>` za enum vrednosti!",
    },
    [2] = {
        patterns = { 'yi"', 'vi"', "<leader>p" },
        steps = {
            'Stani na `CLUSTER_ENV: "production"` i ukucaj `yi"` (Yank Inside `" "`) — kopirao si samo `production`.',
            'Sidji na `APP_ENV: "dev"` (`j`) i ukucaj `vi"<Space>p` (Visual Inside `" "` + Void Paste).',
            'Ponovi `j` pa `vi"<Space>p` na `LOG_ENV` i `METRICS_ENV` — nijednom ne moras opet da kopiras `"production"`!',
        },
        tip = "Kad menjas vise vrednosti istim stringom u YAML-u, `yi\"` pa `vi\"<Space>p` je najbrzi workflow koji postoji.",
    },
    [3] = {
        patterns = { "gcc", "V2jgc" },
        steps = {
            "Stani na `- containerPort: 9999` i ukucaj `gcc` -> linija dobija `#` komentar.",
            "Sidji na `# readinessProbe:` (`j`), ukucaj `V2j` (selektuj 3 linije) pa `gc` -> ceo probe blok je otkomentarisan!",
        },
        tip = "`gcc` radi svuda — Neovim sam zna da u Lua stavlja `--`, a u YAML-u `#`!",
    },
    [4] = {
        patterns = { "V+JK" },
        steps = {
            'Stani na `- "1. wait-for-db"`, pritisni `V` pa `K` jednom da ode na 1. mesto.',
            'Stani na `- "2. run-migrations"`, pritisni `V` pa `KK` da dodje odmah ispod 1.',
            'Proveri redosled: 1 -> 2 -> 3 -> 4 (svi ostali su vec na mestu!).',
        },
        tip = "U YAML listama `V` + `J`/`K` cuva tacno uvlacenje (indentation) bez rizika da pokvaris razmake!",
    },
    [5] = {
        patterns = { "<leader>s" },
        steps = {
            "Stani kursorom bilo gde na rec `legacy_ns_05` (npr. kod `namespace:`).",
            "Pritisni `<Space>s`, ukucaj `prod_payments` i pritisni `<Enter>`.",
            "Sve 4 pojave (ukljucujuci onu usred `db.legacy_ns_05.svc.cluster.local`) menjaju se odjednom!",
        },
        tip = "Zasto `<Space>s` radi i u `db.legacy_ns_05.svc`? Zato sto tacka `.` odvaja reci, pa `\\<legacy_ns_05\\>` tacno pogadja taj segment!",
    },
    [6] = {
        patterns = { 'ysiw"', "cs'\"", "ds)" },
        steps = {
            'Na `REGION: eu_central` stani na `eu_central` i ukucaj `ysiw"` (You Surround Inside Word `"`) -> `"eu_central"`.',
            "Na `PORT: '8080'` stani unutar `'8080'` i ukucaj `cs'\"` (Change Surround `'` u `\"`) -> `\"8080\"`.",
            'Na `TIMEOUT: ("30s")` stani unutar zagrada i ukucaj `ds)` (Delete Surround `)`) -> `"30s"`.',
        },
        tip = "Zapamti trojku Surround glagola: `ys` = dodaj, `cs` = promeni, `ds` = obrisi okruzeno!",
    },
    [7] = {
        patterns = { 'yi"', "<leader>dd", 'vi"', "<leader>p" },
        steps = {
            'Na `memory: "512Mi"` (u `requests`) ukucaj `yi"` (Yank Inside `" "`).',
            "Sidji na `ephemeral-storage: \"OBRISI_ME\"` i obrisi je sa `<Space>dd` (crna rupa — tvoj yank `512Mi` ostaje netaknut!).",
            'Sidji na `memory: "FIXME"` (u `limits`) i ukucaj `vi"<Space>p` -> `"512Mi"`.',
        },
        tip = "Ako ovde pritisnes obican `dd`, izgubices `512Mi` iz registra. `<Space>dd` je navika koja stedi hiljade ponovnih kopiranja.",
    },
    [8] = {
        patterns = { "V+indent" },
        steps = {
            "Stani na `requests:` (trenutno na 0 razmaka), pritisni `V2j` da selektujes sve 3 linije (`requests`, `cpu`, `memory`).",
            "Pritisni `>` -> ceo blok se uvlaci za 2 razmaka (`requests` na 2, `cpu/memory` na 4).",
            "Pritisni `.` (Dot Repeat!) -> ponavlja indent jos jednom! Sada je `requests:` na tacno 4 razmaka, a `cpu` i `memory` na 6!",
        },
        tip = "Taster `.` (tacka) je najpodcenjenija komanda u Vimu: ponavlja poslednju promenu! `V2j>` pa `.` resava YAML indent za sekund.",
    },
    [9] = {
        patterns = { "ciw", "gcc" },
        steps = {
            "Na `runAsNonRoot: false` stani na `false`, ukucaj `ciw` -> `true` -> `<C-c>`.",
            "Sidji na `readOnlyRootFilesystem: false`, stani na `false` i pritisni samo `.` (ponavlja `ciw` + `true`!).",
            "Na `allowPrivilegeEscalation: true` -> `ciw` -> `false` -> `<C-c>`. Na `privileged: true` -> `gcc`.",
        },
        tip = "Gledaj moc tacke `.`: kad na jednoj liniji uradis `ciw` + `true`, na sledecoj samo stanes na `false` i pritisnes `.`!",
    },
    [10] = {
        patterns = { "cs'\"", 'ci"', "<leader>+", "gcc" },
        steps = {
            "Na `host: 'old.example.com'` -> `cs'\"` (u duple navodnike), pa `ci\"` (Change Inside `\" \"`) -> `api.prod.internal` + `<C-c>`.",
            "Na `beta_debug: \"true\"` -> `gcc` (zakomentarisi).",
            "Na `minReplicas: 1` -> `<Space>+` (postaje `2`). Na `maxReplicas: 3` -> `7<Space>+` (postaje `10`).",
        },
        tip = "Za brzu matematiku u YAML-u: `7<Space>+` na `3` odmah daje `10` bez ulaska u Insert mod!",
    },
    [11] = {
        patterns = { "gcc", "cs'\"", "ci'", "ds)" },
        steps = {
            "Na `# - Egress` -> `gcc` (otkomentarisi).",
            "Na `role: 'frontend'` -> `ci'` (Change Inside `' '`) -> `backend` -> `<C-c>`, pa `cs'\"` -> `\"backend\"`.",
            "Na `protocol: 'TCP'` -> `cs'\"` -> `\"TCP\"`. Na `port: (5432)` -> `ds)` -> `5432`.",
        },
        tip = "Svejedno da li prvo radis `cs'\"` pa `ci\"` ili `ci'` pa `cs'\"` — oba prate cistu Vim gramatiku!",
    },
    [12] = {
        patterns = { 'ci"', "<leader>+", "gcc", "ds)" },
        steps = {
            'Na `serviceName: "pg-dev"` -> `ci"` -> `postgres-headless` + `<C-c>`. Na `replicas: 1` -> `2<Space>+` (`3`).',
            'Na `image: "postgres:14.0"` -> `ci"` -> `postgres:16.4-alpine` + `<C-c>`.',
            "Na `PG_DEBUG_SQL: \"true\"` -> `gcc`.",
            'Na `storageClassName: "hdd"` -> `ci"` -> `fast-ssd` + `<C-c>`. Na `storage: ("50Gi")` -> `ds)` -> `"50Gi"`.',
        },
        tip = "`ci\"` je kralj YAML-a: ne moras da pomeris kursor unutra, samo budi na toj liniji i kucaj `ci\"`!",
    },
    [13] = {
        patterns = { 'ci"', "ciw", "cmp", "<leader>dd", "gcc" },
        steps = {
            'Na `schedule: "* * * * *"` -> `ci"` -> `0 2 * * *` + `<C-c>`.',
            "Na `concurrencyPolicy: Allow` -> `ciw`, kucaj `For`, potvrdi `Forbid` sa `<C-y>` (K8s LSP autocomplete!).",
            "Na `successfulJobsHistoryLimit: 100` -> `ciw` -> `3` + `<C-c>`. Na `debug_sleep_13` -> `<Space>dd`.",
            "Na `restartPolicy: Always` -> `ciw`, kucaj `OnF`, potvrdi `OnFailure` sa `<C-y>`. Na `- \"--dry-run\"` -> `gcc`.",
        },
        tip = "U K8s fajlovima `yamlls` zna sve validne enum vrednosti (`Forbid`, `OnFailure`, `IfNotPresent`) — koristi `ciw` + `<C-y>`!",
    },
    [14] = {
        patterns = { "<leader>+", "cs'\"", 'ci"', "ciw", "V+JK" },
        steps = {
            "Na `minAvailable: 0` -> `2<Space>+` (`2`). Na `maxSkew: 5` -> `4<Space>-` (`1`).",
            'Na `topologyKey: \'kubernetes.io/hostname\'` -> `cs\'"` pa `ci"` -> `topology.kubernetes.io/zone` + `<C-c>`.',
            "Na `whenUnsatisfiable: ScheduleAnyway` -> `ciw` -> `DoNotSchedule` + `<C-c>`.",
            "Na `app: checkout` -> `V` pa `K` (pomeri iznad `tier: frontend`).",
        },
        tip = "Za smanjenje broja koristi `<broj><Space>-`: na `5` ukucas `4<Space>-` i odmah dobijes `1`!",
    },
    [15] = {
        patterns = { "<leader>dd", "cs'\"", "gcc", "ciw" },
        steps = {
            "Na `wildcard_hack_15: \"*\"` -> `<Space>dd` (obrisi u void registar).",
            "Na `- 'pods'` -> `cs'\"` (`\"pods\"`). Na `- 'configmaps'` -> `cs'\"` (`\"configmaps\"`).",
            'Na `- "secrets"` -> `gcc`. Na `- "delete"` -> `gcc`.',
            "Na `name: cluster-admin` stani na `cluster-admin` -> `ciW` (veliko `W` hvata i crticu!) -> `readonly-ops` + `<C-c>`.",
        },
        tip = "Pazi na crticu `-` u `cluster-admin`! `ciw` bi promenilo samo `cluster`, dok `ciW` (Change Inside WORD) menja celu rec sa crticom!",
    },
    [16] = {
        patterns = { "gcc", 'ci"', "<leader>+", "ds)", "ciw" },
        steps = {
            'Na `haproxy_debug: "on"` -> `gcc`. Na `host: "portal.apps.dev.local"` -> `ci"` -> `portal.apps.ocp-prod.internal` + `<C-c>`.',
            "Na `weight: 50` -> `50<Space>+` (ili `ciw` -> `100`). Na `targetPort: (8443)` -> `ds)`.",
            "Na `termination: passthrough` -> `ciw` -> `edge` + `<C-c>`.",
            "Na `insecureEdgeTerminationPolicy: Allow` -> `ciw` -> `Redirect` + `<C-c>`.",
        },
        tip = "Jedan pogled na liniju i odmah biras alat: broj u zagradama -> `ds)`, string -> `ci\"`, jedna rec -> `ciw`.",
    },
    [17] = {
        patterns = { "<leader>s", 'ci"', "ciw", "gcc" },
        steps = {
            "Stani na `dev_cluster_17` -> `<Space>s` -> `ocp_prod` + `<Enter>` (menja sve 3 pojave odjednom!).",
            'Na `targetRevision: "HEAD"` -> `ci"` -> `v3.2.0` + `<C-c>`.',
            "Na `prune: false` -> `ciw` -> `true` + `<C-c>`. Na `selfHeal: false` stani na `false` -> `.` (ponovi!).",
            "Na `skipDryRun: true` -> `gcc`. Na `# - CreateNamespace=true` -> `gcc`.",
        },
        tip = "Uvek prvo radi globalne zamene (`<Space>s`), pa tek onda lokalne izmene (`ci\"`, `ciw`, `gcc`).",
    },
    [18] = {
        patterns = { "<leader>s", "ds)", "gcc", "<leader>dd", "ciw" },
        steps = {
            "Stani na `vault_staging_18` -> `<Space>s` -> `vault_prod` + `<Enter>` (menja sve 3 pojave!).",
            'Na `refreshInterval: ("15m")` -> `ds)` -> `"15m"`.',
            "Na `allowInsecureTLS: true` -> `gcc`. Na `plaintext_leak_18: \"hunter2\"` -> `<Space>dd`.",
            "Na `creationPolicy: Orphan` -> `ciw` -> `Owner` + `<C-c>`.",
        },
        tip = "Kod ExternalSecrets i Vault konfiguracija `<Space>s` eliminise rizik da zaboravis da promenis jedan path.",
    },
    [19] = {
        patterns = { "V+JK", 'ci"', "gcc" },
        steps = {
            "Na `alert: HighPodRestarts` -> `V` pa `K` (popni na 1. mesto ispod `rules:`).",
            'Na `for: "1s"` -> `ci"` -> `5m` + `<C-c>`. Na `mute_all_alerts: true` -> `gcc`.',
            'Na `severity: "info"` -> `ci"` -> `critical` + `<C-c>`. Na `team: "unknown"` -> `ci"` -> `sre-platform` + `<C-c>`.',
            'Na `runbook: "TODO"` -> `ci"` -> `https://wiki.internal/oom` + `<C-c>`.',
        },
        tip = "Kad menjas vise stringova zaredom: `j`, `ci\"`, tekst, `<C-c>` postaje ritam kao sviranje instrumenta.",
    },
    [20] = {
        patterns = { "cs'\"", 'ci"', "gcc", "ciw" },
        steps = {
            'Na `operator: \'Equal\'` -> `cs\'"` pa `ci"` -> `Exists` + `<C-c>`.',
            'Na `effect: \'PreferNoSchedule\'` -> `cs\'"` pa `ci"` -> `NoSchedule` + `<C-c>`.',
            'Na `image: "fluent/fluent-bit:1.9"` -> `ci"` -> `fluent/fluent-bit:3.1` + `<C-c>`. Na `drop_all_logs: true` -> `gcc`.',
            'Na `readOnly: false` -> `ciw` -> `true` + `<C-c>`. Na `path: \'/tmp/logs\'` -> `cs\'"` pa `ci"` -> `/var/log/containers` + `<C-c>`.',
        },
        tip = "U istom potezu mozes uraditi i `ci'` + tekst + `<C-c>` + `cs'\"` — kako ti je prirodnije za oko.",
    },
    [21] = {
        patterns = { "<leader>dd", "gcc", 'ci"', "<leader>+" },
        steps = {
            "Na `memory_leak_sim_21: \"yes\"` -> `<Space>dd`. Na `CRASH_ON_START: \"1\"` -> `gcc`.",
            'Na `memory: "32Mi"` -> `ci"` -> `1Gi` + `<C-c>`. Na `cpu: "50m"` -> `ci"` -> `500m` + `<C-c>`.',
            "Na `initialDelaySeconds: 1` -> `29<Space>+` (`30`).",
            "Na `periodSeconds: 1` -> `9<Space>+` (`10`). Na `failureThreshold: 1` -> `4<Space>+` (`5`).",
        },
        tip = "U incidentu u 3 ujutru ne zelis da brises cifre rucno — `ci\"` za limite i `<broj><Space>+` za probe tajmere je munjevito!",
    },
    [22] = {
        patterns = { "<leader>s", "<leader>+", "ciw", "cmp", "ds)", "gcc", "V+JK" },
        steps = {
            "Stani na `broken_dns_22` -> `<Space>s` -> `10.96.0.10` + `<Enter>`.",
            "Na `replicas: 1` -> `2<Space>+` (`3`). Na `dnsPolicy: Default` -> `ciw`, kucaj `Clus` + `<C-y>` (`ClusterFirst`).",
            "Na `ndots: (2)` -> `ds)` (`2`). Na `loop_forward: \"127.0.0.1\"` -> `gcc`.",
            'Na `upstream_1: "1.1.1.1"` -> `V` pa `K` (pomeri iznad `upstream_2`).',
        },
        tip = "Primeti kako jedan incident kombinuje SVE sto si naucio — i svaki deo ima svoj 1-sekundni obrazac!",
    },
    [23] = {
        patterns = { 'ci"', "<leader>dd", "gcc", "cs'\"" },
        steps = {
            'Na `duration: "24h"` -> `ci"` -> `2160h` + `<C-c>`. Na `renewBefore: "1h"` -> `ci"` -> `360h` + `<C-c>`.',
            "Na `expired_override_23: true` -> `<Space>dd`. Na `selfSigned: true` -> `gcc`.",
            'Na `dnsName: "shop.dev.local"` -> `ci"` -> `shop.prod.example.com` + `<C-c>`.',
            "Na `name: 'letsencrypt-staging'` -> `cs'\"` pa stani na `staging` -> `ciw` -> `prod` + `<C-c>`!",
        },
        tip = "Genijalan trik za `'letsencrypt-staging'`: umesto da kucas ceo naziv, `cs'\"` promeni navodnike, a `ciw` na `staging` zameni samo zadnju rec!",
    },
    [24] = {
        patterns = { "<leader>s", "<leader>+", "<leader>dd", "V+JK", "ciw", 'ci"', "ds)", "gcc" },
        steps = {
            "Stani na `beta_mesh_24` -> `<Space>s` -> `prod_mesh` + `<Enter>` (menja sve 3 pojave).",
            "Na `replicas: 1` -> `3<Space>+` (`4`). Na `sidecar_junk_24` -> `<Space>dd`.",
            'U `containers_order`: na `- "envoy-sidecar"` -> `V` pa `JJ` (spusti na 3. mesto ispod `app` -> redosled je `init-config`, `app`, `envoy-sidecar`!).',
            'Na `runAsNonRoot: false` -> `ciw` -> `true`. Na `envoy:v1.20` -> `ci"` -> `envoyproxy/envoy:v1.31` (ili samo `f2` pa `ciw` -> `31`!).',
            "Na `containerPort: (15001)` -> `ds)`. Na `ENVOY_LOG_LEVEL: \"trace\"` -> `gcc`.",
        },
        tip = "Kod `V + J`/`K` cesto je najbrze pomeriti JEDNU pogresnu stavku (`envoy-sidecar` dole 2x) umesto ostale dve gore!",
    },
    [25] = {
        patterns = { "<leader>dd", "<leader>s", "<leader>+", "cs'\"", "ds)", "gcc", "V+JK", 'yi"', "<leader>p", "ciw" },
        steps = {
            "1) Na `cutover_trash_25` -> `<Space>dd`. 2) Na `rc_alpha_25` -> `<Space>s` -> `prod_v5` + `<Enter>` (4 pojave!).",
            "3) Na `replicas: 1` -> `7<Space>+` (`8`). Na `imagePullPolicy: Always` -> `ciw` + `IfNot` + `<C-y>` (`IfNotPresent`).",
            "4) Surround: `'eu-central-1'` -> `cs'\"`; `(\"v5.0.0\")` -> `ds)`; `(8443)` -> `ds)`.",
            "5) `runAsNonRoot: false` -> `ciw` `true`; `# - Egress` -> `gcc`; `chaos_mode: true` -> `gcc`.",
            "6) `cutover_plan`: `1. Preflight` sa `V`+`KK` na vrh; `4. Full cutover` sa `V`+`JJJ` na dno -> redosled 1..4.",
            '7) Na `slack_handler: "Notify SRE Slack"` -> `yi"`, pa na `pre_notify` i `post_notify` po `vi"<Space>p`!',
        },
        tip = "FINAL BOSS savladan! Ovo je realni production cutover manifest koji sad editujes 5x brze nego misem.",
    },
}

-- ============================================================================
-- ANSIBLE & RHEL 9 DOJO (25 NIVOA)
-- ============================================================================
M.ansible = {
    [1] = {
        patterns = { "ciw", "<leader>dd" },
        steps = {
            "Na `hosts: dev_servers` stani na `dev_servers`, ukucaj `ciw` (Change Inside Word) -> `prod_web` + `<C-c>`.",
            "Na `become: false` -> `ciw` -> `true` + `<C-c>`. Na `remote_user: ops` -> `ciw` -> `ansible` + `<C-c>`.",
            "Na `junk_option: remove_me` -> `<Space>dd` (obrisi u crnu rupu).",
        },
        tip = "U Ansible YAML-u `ciw` je osnovni potez za vrednosti bez navodnika (`true`, `false`, `present`, `started`).",
    },
    [2] = {
        patterns = { "ct:", "cmp" },
        steps = {
            "Stani na pocetak reci `yum:` (npr. `^` da skocis na prvi znak linije) i ukucaj `ct:` (Change Till `:`).",
            "Ukucaj `ansible.builtin.dnf` (iskoristi `ansiblels` autocomplete sa `<C-n>`/`<C-y>`) pa `<C-c>` -> dvotacka `:` ostaje netaknuta!",
            "Ponovi `ct:` na `copy:` -> `ansible.builtin.template`, i na `service:` -> `ansible.builtin.systemd`.",
        },
        tip = "`ct:` (Change Till `:`) je NAJBOLJA precica za YAML kljuceve: brise sve do dvotacke, a samu dvotacku cuva!",
    },
    [3] = {
        patterns = { "V+JK" },
        steps = {
            "Stani na `- name: Start and enable nginx` (prvi task, zauzima 4 linije).",
            "Pritisni `V3j` (Visual Line + 3 linije dole) da selektujes CEO taj task blok (name, systemd, name, state).",
            "Pritisni `J` dok ceo task ne sidje na DNO (ispod `Deploy nginx config`) -> redosled je Install -> Deploy -> Start!",
        },
        tip = "Pomeranje celog Ansible taska odjednom: `V3j` selektuje ceo blok, a `J`/`K` ga seli bez ijedne greske u uvlacenju!",
    },
    [4] = {
        patterns = { "ysiw\"", "cs'\"", "ds)", "ciw" },
        steps = {
            'Na `src: app_src` stani na `app_src` -> `ciw` -> `"{{ app_src }}"` + `<C-c>` (ili `ysiw}` + `ysiw}` + `ysiw"`!).',
            "Na `dest: '/etc/nginx/conf.d/app.conf'` -> `cs'\"` (Change Surround `'` u `\"`).",
            'Na `mode: ("0644")` -> `ds)` (Delete Surround `)`) -> `"0644"`.',
        },
        tip = "Probaj surround zabavu za Jinja2: na `app_src` ukucaj `ysiw{` pa `ysiw{` pa `ysa{\"` — zagrade sa razmakom `{` dodaju razmake same!",
    },
    [5] = {
        patterns = { 'yi"', 'vi"', "<leader>p", "ciw", "cmp" },
        steps = {
            'Sidji do handlera `- name: "Restart nginx"` i ukucaj `yi"` (Yank Inside `" "`).',
            'Popni se na oba `notify: "TODO"` i na svakom ukucaj `vi"<Space>p` (Visual Inside `" "` + Void Paste) -> oba postaju `"Restart nginx"`.',
            "U handleru na `state: reloaded` stani na `reloaded` -> `ciw` -> `restarted` (probaj `<C-y>` iz `ansiblels`!).",
        },
        tip = "Handler nazivi moraju da se poklapaju 100% u slovo — zato je `yi\"` + `vi\"<Space>p` sigurniji od kucanja rucno!",
    },
    [6] = {
        patterns = { "gcc", "ciw", "<leader>s" },
        steps = {
            "Stani na `old_repo_06` -> `<Space>s` -> `rhel9_baseos` + `<Enter>` (menja sve 3 pojave odjednom!).",
            "Na `- telnet` -> `gcc` (zakomentarisi nesiguran paket).",
            "Na `state: absent` -> `ciw` -> `present` + `<C-c>`.",
        },
        tip = "Kombinacija `<Space>s` + `gcc` + `ciw` pokriva 80% svakodnevnog odrzavanja Ansible playbook-ova.",
    },
    [7] = {
        patterns = { "ct:", "ds)", "ciw", "gcc" },
        steps = {
            "Stani na `firewalld:` -> `ct:` (Change Till `:`) -> `ansible.posix.firewalld` + `<C-c>`.",
            'Na `port: ("443/tcp")` -> `ds)` -> `"443/tcp"`.',
            "Na `permanent: false` -> `ciw` `true`, na `immediate: false` -> `.` (ponovi!), na `state: disabled` -> `ciw` `enabled`.",
            'Na `- "23/tcp"` -> `gcc` (zakomentarisi telnet port!).',
        },
        tip = "Posle `ciw` `true` na jednoj liniji, na sledecoj `false` liniji samo stisni `.` (tacku) — instant!",
    },
    [8] = {
        patterns = { "ciw", "<leader>dd", "cs'\"", 'ci"' },
        steps = {
            "Na `policy: minimum` -> `ciw` `targeted`. Na `state: disabled` -> `ciw` `enforcing`.",
            "Na `selinux_bypass_08: true` -> `<Space>dd` (obrisi u crnu rupu).",
            "Na `name: 'net.ipv4.ip_forward'` -> `cs'\"` (`\"net.ipv4.ip_forward\"`).",
            'Na `value: "0"` -> `ci"` `1` (ili `f0r1`!). Na `reload: false` -> `ciw` `true`.',
        },
        tip = "Za zamenu jedne cifre kao `\"0\"` u `\"1\"`, `f0r1` (Find `0`, Replace `1`) je jos brze od `ci\"`!",
    },
    [9] = {
        patterns = { "ciw", "V+JK", "gcc", 'ci"' },
        steps = {
            "Na `become: false` -> `ciw` `true`. Na `failed_when: false` -> `gcc`.",
            'U `rescue:` na `msg: "TODO"` -> `ci"` `Rollback triggered`. U `always:` na `state: touch` -> `ciw` `absent`.',
            "Poredjaj blokove (`block:` gore na 1. mesto, `rescue:` u sredinu, `always:` na dno) selektujuci ceo blok sa `V` + `j` pa `J`/`K` (pazi da `- ` ostane na `block:`!).",
        },
        tip = "Kad premestas YAML sekciju koja pocinje sa `- `, obrati paznju da crtica ostane na prvom kljucu itema (`- block:`).",
    },
    [10] = {
        patterns = { "ciw", "ds)", 'ci"', 'yi"', "<leader>p", "gcc" },
        steps = {
            'Na `validate: "true"` -> `ci"` -> `/usr/sbin/sshd -t -f %s` + `<C-c>`.',
            'Na `"PermitRootLogin yes"` stani na `yes` -> `ciw` `no` + `<C-c>`. Na `"PasswordAuthentication yes"` stani na `yes` -> `.` (ponovi!).',
            'Na `- ("Port 2222")` -> `ds)` -> `- "Port 2222"`. Na `- "AllowEmptyPasswords yes"` -> `gcc`.',
            'Iz handlera `"Restart sshd"` uradi `yi"`, pa na `notify: "FIXME"` uradi `vi"<Space>p`!',
        },
        tip = "Unutar stringa `\"PermitRootLogin yes\"`, `ciw` na reci `yes` menja SAMO tu jednu rec bez kucanja celog stringa!",
    },
    [11] = {
        patterns = { 'ci"', "ciw", "gcc", "V+indent" },
        steps = {
            'Na `name: "backup-db.service"` stani na `service` -> `ciw` `timer` + `<C-c>` -> `"backup-db.timer"`!',
            "Na `enabled: false` -> `ciw` `true`, na `daemon_reload: false` -> `.`, na `state: stopped` -> `ciw` `started`.",
            "Na `# masked: false` -> `gcc` (otkomentarisi).",
            "Selektuj sve 4 linije (`enabled`, `daemon_reload`, `state`, `masked`) sa `V3j` i pritisni `>` -> sve 4 idu na tacno 8 razmaka!",
        },
        tip = "U `\"backup-db.service\"` tacka deli reci, pa `ciw` na `service` menja samo ekstenziju u `timer` za 1 sekund!",
    },
    [12] = {
        patterns = { 'ci"', "cs'\"", "V+JK", "gcc" },
        steps = {
            'Na `when: ansible_os_family == "Debian"` -> `ci"` -> `RedHat` + `<C-c>`.',
            'Na `tags: [\'old\']` stani unutar `[...]` -> `ci[` (Change Inside `[ ]`!) -> `"rhel9", "base"` + `<C-c>`.',
            'U `loop:` zakomentarisi `- "ftp"` sa `gcc`, pa `V` + `J`/`K` poredjaj: `ca-certificates`, `curl`, `jq`, `tmux`.',
        },
        tip = "Upoznaj `ci[` (Change Inside `[ ]`)! Ista gramatika kao `ci\"` i `ci'`, samo za uglaste zagrade YAML listi!",
    },
    [13] = {
        patterns = { 'ci"', "ds)", "ciw", "gcc", "<leader>+" },
        steps = {
            'Na `url: "http://localhost/health"` -> `ci"` -> `https://api.prod.internal/health` + `<C-c>`.',
            "Na `status_code: (200)` -> `ds)` (`200`). Na `validate_certs: false` -> `ciw` `true`. Na `ignore_tls_hack: true` -> `gcc`.",
            "Na `retries: 1` -> `9<Space>+` (`10`). Na `delay: 1` -> `4<Space>+` (`5`).",
        },
        tip = "Brojevi u `retries` i `delay` su stvoreni za `<broj><Space>+` — npr. `9<Space>+` na `1` odmah daje `10`.",
    },
    [14] = {
        patterns = { "ct:", 'ci"', "ciw", "cs'\"", "gcc" },
        steps = {
            "Na `docker_container:` -> `ct:` -> `containers.podman.podman_container` + `<C-c>`.",
            'Na `image: "quay.io/org/agent:dev"` stani na `dev` -> `ciw` `v2.1` + `<C-c>`.',
            "Na `state: stopped` -> `ciw` `started`. Na `restart_policy: 'no'` -> `cs'\"` pa `ci\"` `always`. Na `privileged: true` -> `gcc`.",
            "Na `ports: ['9090:9090']` -> `cs'\"` pa `ci\"` `8080:8080` + `<C-c>`.",
        },
        tip = "Na `quay.io/org/agent:dev` dvotacka deli rec, pa `ciw` na `dev` menja samo tag bez ponovnog kucanja celog URL-a!",
    },
    [15] = {
        patterns = { "<leader>s", "<leader>+", 'ci"', "gcc", "V+JK" },
        steps = {
            "Stani na `old_vip_15` -> `<Space>s` -> `10.50.0.10` + `<Enter>` (menja obe pojave!).",
            'Na `priority: 100` -> `50<Space>+` (`150`). Na `vrrp_state: "BACKUP"` -> `ci"` `MASTER`. Na `check_interval: 10` -> `8<Space>-` (`2`).',
            "Na `nopreempt_bug: true` -> `gcc`.",
            "Selektuj ceo task `Configure haproxy` (`V3j`) i podigni ga sa `K` iznad `Configure keepalived`.",
        },
        tip = "U HAProxy/Keepalived playbook-ovima `V3j` + `K` je najsigurniji nacin da zamenis redosled dva taska.",
    },
    [16] = {
        patterns = { 'ci"', "cs'\"", "gcc", "ciw" },
        steps = {
            'Na `name: "temp_user"` -> `ci"` `sre_admin`. Na `groups: \'users\'` -> `cs\'"` pa `ci"` `wheel`.',
            'Na `shell: "/sbin/nologin"` -> `ci"` `/bin/bash`. Na `password: "123456"` -> `gcc`.',
            "Na `state: absent` -> `ciw` `present`. Na `exclusive: false` -> `ciw` `true`.",
        },
        tip = "Obrati paznju na navodnike: kad menjas `'users'` u `\"wheel\"`, `cs'\"` + `ci\"` je cisto i bez rucnog brisanja apostrofa.",
    },
    [17] = {
        patterns = { 'ci"', "ds)", "gcc", "ciw" },
        steps = {
            'Na `minute: "*"` -> `ci"` `30` + `<C-c>`. Na `hour: "*"` -> `ci"` `3` + `<C-c>`.',
            'Na `user: ("root")` -> `ds)` -> `"root"`.',
            'Na `job: "echo test"` -> `ci"` `/usr/local/bin/cleanup.sh` + `<C-c>`.',
            "Na `disabled: true` -> `gcc`. Na `state: absent` -> `ciw` `present`.",
        },
        tip = "`ci\"` radi savrseno cak i kad je unutra samo 1 karakter kao `\"*\"`!",
    },
    [18] = {
        patterns = { "cs'\"", 'ci"', "ciw", "<leader>dd" },
        steps = {
            "Na `owner: 'root'` -> `cs'\"` pa `ci\"` `nginx` + `<C-c>`.",
            "Na `group: 'root'` -> `cs'\"` pa `ci\"` `nginx` (ili kopiraj `nginx` sa `yi\"` pa `vi'<Space>p` + `cs'\"`!).",
            "Na `mode: '0777'` -> `cs'\"` pa `ci\"` `0640`. Na `backup: false` -> `ciw` `true`.",
            'Na `validate: "true"` -> `ci"` `nginx -t -c %s`. Na `temp_copy_18: "junk"` -> `<Space>dd`.',
        },
        tip = "`validate: \"nginx -t -c %s\"` je i dobra produkcijska navika: Ansible testira config pre nego sto pregazi postojeci!",
    },
    [19] = {
        patterns = { 'ci"', "ciw", "gcc" },
        steps = {
            'Na `version: "main"` -> `ci"` `v3.5.0` + `<C-c>`.',
            "Na `force: true` -> `ciw` `false`. Na `update: false` -> `ciw` `true`. Na `accept_hostkey: false` -> `gcc`.",
            "Na `changed_when: true` -> `ciw` `git_result.changed` + `<C-c>`.",
        },
        tip = "U jednom prolazu od vrha do dna bez vracanja: `ci\"`, `ciw`, `ciw`, `gcc`, `ciw`!",
    },
    [20] = {
        patterns = { "ciw", "<leader>+", "gcc" },
        steps = {
            "Na `security: false` -> `ciw` `true`, na `bugfix: false` -> `.` (ponovi!), na `state: present` -> `ciw` `latest`.",
            "Na `reboot_timeout: 60` -> `ciw` `600` (ili `540<Space>+`).",
            "Na `pre_reboot_delay: 0` -> `15<Space>+` (`15`). Na `force_reboot_20: true` -> `gcc`.",
        },
        tip = "Uvek biraj kraci put: za `0 -> 15` je `15<Space>+` brze, a za `60 -> 600` je `A0` (Append `0` na kraj linije!) samo 2 tastera!",
    },
    [21] = {
        patterns = { "ciw", "gcc", 'yi"', 'vi"', "<leader>p", "V+JK" },
        steps = {
            "Na `serial: 100` -> `ciw` `2`. Na `max_fail_percentage: 99` -> `ciw` `10`. Na `any_errors_fatal: false` -> `ciw` `true`. Na `force_reboot_all` -> `gcc`.",
            'Na `quorum_label: "Verify cluster quorum"` -> `yi"`, pa na oba `"TODO_CHECK"` (u `pre_tasks` i `post_tasks`) po `vi"<Space>p`!',
            "Selektuj task `Backup etcd` (2 linije: `Vj`) i popni ga sa `K` iznad `Upgrade kubeadm`.",
        },
        tip = "Uvek prvo backup pa upgrade — i u Vim-u `Vj` + `KKKK` menja redosled dva taska za 1 sekund!",
    },
    [22] = {
        patterns = { "<leader>s", "ciw", "cs'\"", 'ci"', "gcc" },
        steps = {
            "Stani na `vault_old_22` -> `<Space>s` -> `vault_prod` + `<Enter>` (menja obe pojave).",
            "Na `gather_facts: false` -> `ciw` `true`. Na `no_log: false` -> `.` (ponovi!).",
            "Na `mode: '0644'` -> `cs'\"` pa `ci\"` `0600` (ili `f4` pa `r0`, `f4` pa `r0`).",
            "Na `debug_print_secret: true` -> `gcc`.",
        },
        tip = "U Ansible-u `no_log: true` + `mode: \"0600\"` je obavezna sigurnosna kombinacija za sve tajne.",
    },
    [23] = {
        patterns = { "ciw", "gcc", "V+JK", 'yi"', 'vi"', "<leader>p" },
        steps = {
            "Na `serial: 10` -> `ciw` `1`. Na `become: false` -> `ciw` `true`. Na `ignore_errors: true` -> `gcc`.",
            "Selektuj `Enable node` (2 linije: `Vj`) i spusti ga sa `J` skroz na dno ispod `Upgrade app` (ukljucujuci i `notify`) -> Drain -> Upgrade -> Enable!",
            'Iz handlera `"Reload haproxy"` uradi `yi"`, pa na `notify: "FIXME"` uradi `vi"<Space>p`.',
        },
        tip = "Kad radis rolling deploy, pomeranje jednog taska (`Enable node` na kraj) resava ceo redosled u 1 selekciji!",
    },
    [24] = {
        patterns = { "ciw", "gcc", "<leader>dd", "V+JK", "ct:", 'yi"', "<leader>p" },
        steps = {
            "Na `hosts: rhel9_dev` -> `ciw` `rhel9_prod`. `become: false` -> `ciw` `true`. `serial: 5` -> `4<Space>-` (`1`). `selinux_state: permissive` -> `ciw` `enforcing`.",
            "Na `disable_firewall: true` -> `gcc`. Na `legacy_hack_24` -> `<Space>dd`.",
            "U `phases:` sa `V` + `J`/`K` poredjaj 1. Firewall -> 2. Packages -> 3. Config -> 4. Start.",
            "Na `yum:` -> `ct:` `ansible.builtin.dnf`; na `service:` -> `ct:` `ansible.builtin.systemd`.",
            'Na handleru `"Reload nginx"` -> `yi"`, pa na oba `notify: "TODO"` po `vi"<Space>p`!',
        },
        tip = "Odradi prvo brisanje (`<Space>dd`), pa kopiranje (`yi\"`), pa lepljenje (`vi\"<Space>p`) — tako nikad ne gubis registar!",
    },
    [25] = {
        patterns = { "<leader>dd", "<leader>s", "<leader>+", "cs'\"", "ds)", "gcc", "V+JK", 'yi"', "<leader>p", "ciw" },
        steps = {
            "1) Na `cutover_trash_25` -> `<Space>dd`. 2) Na `rc_alpha_25` -> `<Space>s` -> `prod_v5` + `<Enter>` (4 pojave!).",
            "3) Na `become: false` -> `ciw` `true`; `serial: 5` -> `4<Space>-` (`1`); `no_log: false` -> `ciw` `true`; `retries: 1` -> `4<Space>+` (`5`).",
            "4) Surround: `'eu-central-1'` -> `cs'\"`; `(\"0600\")` -> `ds)`; `(8443)` -> `ds)`. 5) `chaos_mode: true` -> `gcc`.",
            "6) `cutover_plan`: `1. Preflight` sa `V`+`KK` na vrh; `4. Full cutover` sa `V`+`JJJ` na dno -> 1..4.",
            '7) Iz handlera `"Notify SRE Slack"` -> `yi"`, pa na oba `notify: "FIXME"` po `vi"<Space>p`!',
        },
        tip = "GRAND MASTER! Sada znas ceo Vim jezik — sve 83 vezbe u Core, K8s i Ansible su varijacije istih 10 obrazaca!",
    },
}

return M
