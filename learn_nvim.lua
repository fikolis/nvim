-- ============================================================================
--  NEOVIM DOJO — 33 NIVOA (MODIFIKOVANI VIM GOLF ZA TVOJ CONFIG)
-- ============================================================================
--  Kako se igra:
--    1. Otvori ovaj fajl: `nvim learn_nvim.lua`
--    2. Radi nivoe redom (ili skoci: `/NIVO 15`, ili `:DojoNext`).
--    3. Provera je automatska. Kad nivo prodje, pored naslova stane ✓.
--       Delimican napredak je • i n/m. Winbar pokazuje skor i sta fali.
--    4. `:Dojo` lista sve nivoe. `:DojoNext` skace na prvi nedovrsen.
--    5. Vise igraca (Save / New / Load Game):
--         - `:DojoNew [ime]`  = New Game (novi igrac ili pocetak od 0/33)
--         - `:DojoSave [ime]` (ili `:w`) = Save Game (cuva napredak + kod, fajl na disku ostaje cist!)
--         - `:DojoLoad [ime]` (ili `:DojoContinue`) = izaberi igraca i nastavi gde je stao
--         - `:DojoDelete [ime]` = obrisi sacuvanog igraca
--    6. `:DojoReset` vraca ceo tekst sa diska (sacuvani napredak ostaje).
--       `:DojoResetLevel [N]` vraca samo trenutni (ili zadati) nivo i brise njegov check.
--       `:DojoResetAll` brise napredak i runde trenutnog igraca.
--    7. Fajl na disku se NIKAD ne menja — svi save-ovi idu u Neovim data folder.
--       Kad zavrsis svih 33, bafer se sam vrati na pocetak i poveca broj rundi.
--    8. Pogresan potez: `u` undo, `<leader>u` Undotree.
--    9. Ne pritiskaj `<leader><leader>` ovde — source bi pokvario vezbu.
--   10. Leader je <Space>. Podsetnik: `<leader>?`
--
--  Zasto `.lua` umesto `.txt`?
--    Zato sto u `.lua` fajlu REALNO rade Treesitter (`af`/`if`/`aa`/`ia`/`]f`),
--    LSP (`gd`, `K`, `<leader>vrn`, `[d`/`]d`), `gcc` komentari, Trouble i
--    Conform (`<leader>f`) — sve direktno na ovim primerima!
-- ============================================================================

local M = {}

-- ============================================================================
--  TIER 1: OSNOVE KRETANJA, CENTRIRANJE I OTKRIVANJE PRECICA (Nivoi 1-5)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- NIVO 01 / 33 — Cheatsheet & Discovery (Zagrevanje)
-- Precice: <leader>?  |  <leader>wk  |  <leader>w?
-- ZADATAK:
--   1. Pritisni `<leader>?` i ukucaj `harpoon` da pronadjes sve Harpoon precice.
--      Pritisni `<Esc>` za izlaz.
--   2. Pritisni `<leader>wk` da vidis sve grupe precica (Which-Key).
--   3. Pritisni `<leader>w?` da vidis samo buffer-local precice za ovaj fajl.
-- PROVERA: Pronasao si na kom tasteru je `Snacks.lazygit` i `Undotree`.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NIVO 02 / 33 — Centrirano skrolovanje i pretraga
-- Precice: <C-d>  |  <C-u>  |  /  |  n  |  N
-- ZADATAK:
--   1. Pritisni `<C-d>` dva puta pa `<C-u>` dva puta — primeti kako kursor
--      uvek ostaje u centru ekrana (`zz`).
--   2. Ukucaj `/PING_META` pa `<Enter>`.
--   3. Skaci kroz pogotke sa `n` i vracaj se sa `N` (svaki put centrirano).
--   4. Pomeri kursor sa `j` — primeti kako highlight sam nestane (`nohlsearch`).
-- ----------------------------------------------------------------------------
local nivo_02_targets = {
    "PING_META_1",
    "noise_a",
    "noise_b",
    "PING_META_2",
    "noise_c",
    "PING_META_3",
}

-- ----------------------------------------------------------------------------
-- NIVO 03 / 33 — Spajanje linija bez pomeranja kursora
-- Precica: J  (tvoj remap: `mzJ`z` — spaja liniju ispod, kursor ostaje!)
-- Par: 3 poteza
-- ZADATAK: Stani na pocetak linije `local nivo_03_cmd = "kubectl"` i spoji sve 4
--          linije u jednu pomocu `J` (3x). Primeti da kursor ne bezi!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_03_cmd = "kubectl"
    .. " get pods"
    .. " -n production"
    .. " -o wide"

-- OCEKIVANI REZULTAT:
-- local nivo_03_cmd = "kubectl" .. " get pods" .. " -n production" .. " -o wide"

-- ----------------------------------------------------------------------------
-- NIVO 04 / 33 — Pomeranje linija u Visual modu
-- Precice: V (Visual Line)  |  J (pomeri dole)  |  K (pomeri gore)
-- Par: 8 poteza
-- ZADATAK: Poredjaj korake deploy pipeline-a od 1 do 5!
--          Selektuj liniju (ili vise linija) sa `V`, pa ih pomeraj sa `J`/`K`.
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_04_pipeline = {
    "3. docker push",
    "1. git pull",
    "5. healthcheck",
    "2. docker build",
    "4. helm upgrade",
}

-- OCEKIVANI REZULTAT:
-- local nivo_04_pipeline = {
--     "1. git pull",
--     "2. docker build",
--     "3. docker push",
--     "4. helm upgrade",
--     "5. healthcheck",
-- }

-- ----------------------------------------------------------------------------
-- NIVO 05 / 33 — Brzi izlaz iz Insert moda sa <C-c>
-- Precice: ci"  |  <C-c> (tvoj remap za <Esc> u Insert modu)
-- Par: 6 poteza (bez teksta)
-- ZADATAK:
--   1. Promeni `"BROKEN"` u `"HEALTHY"` pomocu `ci"`.
--   2. Promeni `"v0.0.1"` u `"v1.0.0"` pomocu `ci"`.
--   3. Izadji iz Insert moda pomocu `<C-c>` (umesto `<Esc>`).
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_05_status = "BROKEN"
local nivo_05_version = "v0.0.1"

-- OCEKIVANI REZULTAT:
-- local nivo_05_status = "HEALTHY"
-- local nivo_05_version = "v1.0.0"

-- ============================================================================
--  TIER 2: REGISTRI, CLIPBOARD I VOID DELETE — PRIMEAGEN KLASICI (Nivoi 6-10)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- NIVO 06 / 33 — Paste bez gubljenja yanka ("greatest remap ever")
-- Precice: yi"  |  vi"  |  <leader>p  (`"_dP` u Visual modu)
-- Par: 12 poteza
-- ZADATAK: Kopiraj `"8443"` sa `yi"`, pa zameni SVE TRI pogresne vrednosti
--          (`"8080"`, `"9000"`, `"3000"`) koristeci `vi"<leader>p` — BEZ
--          ponovnog kopiranja `"8443"`!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_06_good_port = "8443"
local nivo_06_ports = {
    api = "8080",
    auth = "9000",
    metrics = "3000",
}

-- OCEKIVANI REZULTAT:
--     api = "8443",
--     auth = "8443",
--     metrics = "8443",

-- ----------------------------------------------------------------------------
-- NIVO 07 / 33 — Brisanje u "crnu rupu" (Void Register)
-- Precice: yiw  |  <leader>d  (`"_d` u Normal/Visual modu)  |  p
-- Par: 10 poteza
-- ZADATAK:
--   1. Kopiraj rec `prod_secret_key` sa `yiw`.
--   2. Obrisi celu liniju `local nivo_07_junk = "OBRISI_ME"` sa `<leader>dd`
--      (ili `V<leader>d`) da NE pregazis registar!
--   3. Zameni `FIXME` na sledecoj liniji sa `viw<leader>p` (i dalje imas
--      `prod_secret_key` u registru!).
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_07_source = "prod_secret_key"
local nivo_07_junk = "OBRISI_ME"
local nivo_07_target = "FIXME"

-- OCEKIVANI REZULTAT:
-- local nivo_07_source = "prod_secret_key"
-- local nivo_07_target = "prod_secret_key"

-- ----------------------------------------------------------------------------
-- NIVO 08 / 33 — System Clipboard Yank
-- Precice: <leader>y  |  <leader>Y
-- ZADATAK:
--   1. Stani na liniju ispod i pritisni `<leader>Y` (kopira celu liniju u
--      macOS clipboard — mozes da probas Cmd+V u drugom prozoru!).
--   2. Selektuj samo URL unutar navodnika (`vi"`) i pritisni `<leader>y`.
-- ----------------------------------------------------------------------------
local nivo_08_url = "https://github.com/folke/snacks.nvim"

-- ----------------------------------------------------------------------------
-- NIVO 09 / 33 — Instant zamena reci pod kursorom svuda u fajlu
-- Precica: <leader>s  (`:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI`)
-- Par: 1 precica + novo ime + Enter!
-- ZADATAK: Stani na rec `stari_klaster_09` (bilo gde) i pritisni `<leader>s`.
--          Ukucaj `novi_klaster_09` i pritisni `<Enter>`.
--          Sve 4 pojave ce se promeniti odjednom!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_09_cfg = {
    primary = "stari_klaster_09",
    backup = "stari_klaster_09",
    dns = "stari_klaster_09",
    tag = "stari_klaster_09",
}

-- OCEKIVANI REZULTAT: Sve 4 vrednosti su "novi_klaster_09".

-- ----------------------------------------------------------------------------
-- NIVO 10 / 33 — Built-in komentari (Neovim 0.10+ / 0.12)
-- Precice: gcc (jedna linija)  |  gc + motion (npr. `gc2j` ili `Vjjgc`)
-- Par: 5 poteza
-- ZADATAK:
--   1. Zakomentarisi liniju `debug = true` pomocu `gcc`.
--   2. Otkomentarisi 3 linije `tls_*` odjednom sa `V2jgc` (ili `gc2j`).
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_10_server = {
    debug = true,
    -- tls_enabled = true,
    -- tls_cert = "/etc/ssl/cert.pem",
    -- tls_key = "/etc/ssl/key.pem",
}

-- OCEKIVANI REZULTAT:
-- local nivo_10_server = {
--     -- debug = true,
--     tls_enabled = true,
--     tls_cert = "/etc/ssl/cert.pem",
--     tls_key = "/etc/ssl/key.pem",
-- }

-- ============================================================================
--  TIER 3: SURROUND MAJSTORSTVO (`nvim-surround`) (Nivoi 11-14)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- NIVO 11 / 33 — Dodaj okruzivanje (`ys`)
-- Precice: ysiw"  |  ysiw'  |  ysiw)  |  yss)
-- Par: 12 poteza
-- ZADATAK:
--   1. Stani na `eu_west` -> `ysiw"` da postane `"eu_west"` (vec je unutar
--      tabele, bez navodnika ovde ispod je promenljiva; stavi je u navodnike).
--   2. Stani na `my_app` -> `ysiw'` da postane `'my_app'`.
--   3. Stani na `x + y` (selektuj ili `ysa` / `ys3w)`) -> obavij u `(x + y)`.
--      Savet: za `(` bez razmaka koristi `)` a za `( ` sa razmakom koristi `(`.
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local eu_west, my_app, x, y = "eu", "app", 1, 2
local nivo_11_region = eu_west
local nivo_11_name = my_app
local nivo_11_sum = x + y * 2

-- OCEKIVANI REZULTAT:
-- local nivo_11_region = "eu_west"
-- local nivo_11_name = 'my_app'
-- local nivo_11_sum = (x + y) * 2

-- ----------------------------------------------------------------------------
-- NIVO 12 / 33 — Promeni okruzivanje (`cs`)
-- Precice: cs"'  |  cs'"  |  cs)}  |  cs])
-- Par: 9 poteza
-- ZADATAK:
--   1. Promeni `'ansible'` -> `"ansible"` pomocu `cs'"`.
--   2. Promeni `"terraform"` -> `'terraform'` pomocu `cs"'`.
--   3. Promeni `("packer")` -> `{"packer"}` pomocu `cs)}`.
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_12_a = 'ansible'
local nivo_12_b = "terraform"
local nivo_12_c = ("packer")

-- OCEKIVANI REZULTAT:
-- local nivo_12_a = "ansible"
-- local nivo_12_b = 'terraform'
-- local nivo_12_c = {"packer"}

-- ----------------------------------------------------------------------------
-- NIVO 13 / 33 — Obrisi okruzivanje (`ds`)
-- Precice: ds"  |  ds)  |  ds}
-- Par: 9 poteza
-- ZADATAK:
--   1. Skini spoljne zagrade oko `(42)` sa `ds)`.
--   2. Skini visak zagrada oko `((100))` (dva puta `ds)`).
--   3. Skini navodnike oko `"true"` sa `ds"` da postane boolean `true`.
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_13_num = (42)
local nivo_13_deep = ((100))
local nivo_13_flag = "true"

-- OCEKIVANI REZULTAT:
-- local nivo_13_num = 42
-- local nivo_13_deep = 100
-- local nivo_13_flag = true

-- ----------------------------------------------------------------------------
-- NIVO 14 / 33 — Surround Golf Combo!
-- Precice: ds)  |  cs'"  |  ysiw"
-- Par: 11 poteza
-- ZADATAK: Pretvori tabelu ispod u cistu tabelu sa duplim navodnicima i bez
--          suvisnih zagrada.
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local host_name = "srv-01"
local nivo_14_node = {
    name = (host_name),
    role = 'worker',
    env = ("prod"),
}

-- OCEKIVANI REZULTAT:
-- local nivo_14_node = {
--     name = "host_name",
--     role = "worker",
--     env = "prod",
-- }

-- ============================================================================
--  TIER 4: TREESITTER TEXTOBJECTS & NAVIGACIJA KODA (Nivoi 15-19)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- NIVO 15 / 33 — Skakanje izmedju funkcija (`]f` / `[f`)
-- Precice: ]f (sledeca funkcija)  |  [f (prethodna funkcija)
-- ZADATAK: Stani na `nivo_15_alpha`, pa skaci sa `]f` kroz sve 4 funkcije i
--          vrati se nazad sa `[f`. Pronadji u kojoj funkciji je tajna sifra!
-- ----------------------------------------------------------------------------
local function nivo_15_alpha()
    return "nista ovde"
end

local function nivo_15_beta()
    return "ni ovde"
end

local function nivo_15_gamma()
    return "TAJNA_SIFRA: NEOVIM_0_12"
end

local function nivo_15_delta()
    return "kraj"
end

-- ----------------------------------------------------------------------------
-- NIVO 16 / 33 — Unutrasnjost funkcije (`if` = `@function.inner`)
-- Precice: dif (obrisi telo funkcije)  |  cif (zameni telo funkcije)
-- Par: 3 poteza (`cif` + nova linija)
-- ZADATAK: Stani bilo gde unutar `nivo_16_bloated` i zameni CELO telo
--          funkcije jednom linijom: `return a + b` koristeci `cif`!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local function nivo_16_bloated(a, b)
    local tmp1 = a * 1
    local tmp2 = b * 1
    local res = tmp1 + tmp2
    return res
end

-- OCEKIVANI REZULTAT:
-- local function nivo_16_bloated(a, b)
--     return a + b
-- end

-- ----------------------------------------------------------------------------
-- NIVO 17 / 33 — Cela funkcija (`af` = `@function.outer`)
-- Precice: daf (obrisi celu funkciju)  |  yaf (kopiraj celu funkciju)
-- Par: 3 poteza (`daf`)
-- ZADATAK: Stani bilo gde u funkciji `nivo_17_deprecated` i obrisi je
--          KOMPLETNO (od `local function` do `end`) jednim potezom: `daf`!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local function nivo_17_keep_me()
    return "ostajem"
end

local function nivo_17_deprecated()
    local old = "obrisi me celu"
    return old
end

-- OCEKIVANI REZULTAT: Ostaje samo `nivo_17_keep_me`.

-- ----------------------------------------------------------------------------
-- NIVO 18 / 33 — Parametri funkcije (`ia` / `aa` = `@parameter.inner/outer`)
-- Precice: cia (promeni argument)  |  daa (obrisi parametar + zarez!)
-- Par: 8 poteza
-- ZADATAK:
--   1. U definiciji `nivo_18_deploy`, obrisi parametar `unused_flag` pomocu
--      `daa` (primeti da Treesitter brise i zarez!).
--   2. U pozivu `nivo_18_call`, stani na `"staging"` i zameni ga u `"prod"`
--      pomocu `cia`.
--   3. U istom pozivu obrisi argument `false` pomocu `daa`.
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local function nivo_18_deploy(env, unused_flag, replicas)
    return env .. ":" .. tostring(replicas)
end

local function nivo_18_call()
    return nivo_18_deploy("staging", false, 3)
end

-- OCEKIVANI REZULTAT:
-- local function nivo_18_deploy(env, replicas)
--     return env .. ":" .. tostring(replicas)
-- end
-- (i u pozivu: `nivo_18_deploy("prod", 3)` — obrisi i `false` sa `daa`!)

-- ----------------------------------------------------------------------------
-- NIVO 19 / 33 — Treesitter + Visual Move Combo
-- Precice: vaf (selektuj celu funkciju)  |  J / K (pomeri je gore/dole)
-- Par: 7 poteza
-- ZADATAK: Stani u `nivo_19_second`, pritisni `vaf` pa je pomeri sa `K`
--          ISPRED `nivo_19_first` (ili obrnuto: `nivo_19_first` iznad).
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local function nivo_19_second()
    return 2
end

local function nivo_19_first()
    return 1
end

-- OCEKIVANI REZULTAT: `nivo_19_first` je iznad `nivo_19_second`.

-- ============================================================================
--  TIER 5: SNACKS PICKER, OIL, HARPOON, ZEN & UNDOTREE (Nivoi 20-24)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- NIVO 20 / 33 — Snacks Picker: fajlovi, git fajlovi, baferi, help
-- Precice: <leader>pf  |  <C-p>  |  <leader>pb  |  <leader>vh
-- ZADATAK:
--   1. Pritisni `<leader>pf`, ukucaj `ai.lua` i otvori ga (`<Enter>`).
--   2. Pritisni `<leader>pb` (Buffers) i vrati se na `learn_nvim.lua`.
--   3. Pritisni `<C-p>` (Git files) i proveri koji fajlovi su u gitu.
--   4. Pritisni `<leader>vh`, ukucaj `undotree` i pogledaj help.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NIVO 21 / 33 — Snacks Grep: live grep, word i WORD
-- Precice: <leader>ps  |  <leader>pws  |  <leader>pWs
-- ZADATAK:
--   1. Stani na rec `Snacks` ispod i pritisni `<leader>pws` (grep word) —
--      vidi gde se sve koristi u tvom configu!
--   2. Stani na `k8s-prod-eu-west-1` i probaj `<leader>pws` (trazi samo deo
--      izmedju crtica) vs `<leader>pWs` (trazi CELU rec sa crticama!).
--   3. Pritisni `<leader>ps` i kucaj `display` ili `terminal`.
-- ----------------------------------------------------------------------------
local nivo_21_demo = {
    plugin = "Snacks",
    cluster = "k8s-prod-eu-west-1",
}

-- ----------------------------------------------------------------------------
-- NIVO 22 / 33 — Oil fajl menadzer (editovanje foldera kao bafera)
-- Precice: - (otvori Oil u trenutnom folderu)  |  <leader>pv (netrw)
-- ZADATAK:
--   1. Pritisni `-` da otvoris `~/.config/nvim/` u Oil-u.
--   2. Kreci se `j`/`k`, udji u `lua/fikolis/lazy/` sa `<Enter>`, vrati se
--      nivo gore sa `-`.
--   3. Vrati se nazad na `learn_nvim.lua` (`<Enter>` na fajlu ili `<C-o>`).
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NIVO 23 / 33 — Harpoon brzina (ThePrimeagen core workflow!)
-- Precice: <leader>a  |  <C-e>  |  <C-j> <C-k> <C-h> <C-l>  |  <C-S-P> <C-S-N>
-- ZADATAK:
--   1. Dodaj `learn_nvim.lua` u Harpoon sa `<leader>a`.
--   2. Otvori `lua/fikolis/remap.lua` (`<leader>pf`) i dodaj ga sa `<leader>a`.
--   3. Otvori `lua/fikolis/ai.lua` i dodaj ga sa `<leader>a`.
--   4. Pritisni `<C-e>` da vidis Harpoon listu (mozes i da menjas redosled!).
--   5. Leti izmedju fajlova na 1 klik: `<C-j>` (fajl 1), `<C-k>` (fajl 2),
--      `<C-h>` (fajl 3) — bez ikakvog menija!
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NIVO 24 / 33 — Zen Mode & Built-in Undotree (Neovim 0.12)
-- Precice: <leader>zz  |  <leader>zZ  |  <leader>u
-- ZADATAK:
--   1. Probaj fokus mod: `<leader>zz` (sirina 90 sa brojevima), pa opet
--      `<leader>zz` da izadjes. Probaj i minimalni `<leader>zZ`.
--   2. Na liniji ispod promeni `"PRVA"` -> `"DRUGA"`, uradi `u` (undo),
--      pa promeni `"PRVA"` -> `"TRECA"` (napravio si 2 grane istorije!).
--   3. Pritisni `<leader>u` da otvoris Undotree i vrati se na `"DRUGA"`!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_24_history = "PRVA"

-- ============================================================================
--  TIER 6: LSP, COMPLETION, FORMATTING & TROUBLE (Nivoi 25-28)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- NIVO 25 / 33 — LSP Navigacija: Go to Definition, Hover, References
-- Precice: gd  |  K  |  <leader>vrr  |  <leader>vws  |  <C-o> (nazad!)
-- ZADATAK:
--   1. Stani na poziv `nivo_25_calc_replicas` u funkciji `nivo_25_usage`.
--   2. Pritisni `K` da vidis hover dokumentaciju funkcije.
--   3. Pritisni `gd` da skocis na njenu definiciju (vrati se sa `<C-o>`).
--   4. Pritisni `<leader>vrr` da vidis sve njene reference u fajlu.
--   5. Pritisni `<leader>vws` i ukucaj `nivo_25` (workspace symbols).
-- ----------------------------------------------------------------------------

--- Izracunava broj replika za dati broj nodova.
---@param nodes integer Broj worker nodova
---@param factor integer Faktor replikacije
---@return integer
local function nivo_25_calc_replicas(nodes, factor)
    return nodes * factor
end

local function nivo_25_usage()
    local a = nivo_25_calc_replicas(3, 2)
    local b = nivo_25_calc_replicas(5, 3)
    return a + b
end

-- ----------------------------------------------------------------------------
-- NIVO 26 / 33 — LSP Rename, Signature Help & Blink Completion
-- Precice: <leader>vrn  |  <C-Space>  |  <C-n> / <C-p>  |  <C-y>  |  <C-h> (i)
-- ZADATAK:
--   1. Stani na `stari_brojac` i pritisni `<leader>vrn` — preimenuj ga u
--      `novi_brojac` (LSP menja SVE pojave inteligentno, ne samo tekst!).
--   2. U Insert modu na dnu funkcije otkucaj `nivo_25_` i probaj `<C-n>` /
--      `<C-p>` za izbor i `<C-y>` za potvrdu (`blink.cmp`).
--   3. Unutar zagrada `nivo_25_calc_replicas(|)` u Insert modu pritisni
--      `<C-h>` za Signature Help!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local function nivo_26_rename_demo()
    local stari_brojac = 10
    stari_brojac = stari_brojac + 5
    return stari_brojac
end

-- ----------------------------------------------------------------------------
-- NIVO 27 / 33 — Dijagnostika & Trouble
-- Precice: ]d / [d  |  <leader>vd  |  <leader>vca  |  <leader>qb  |  <leader>qs  |  <leader>pd
-- ZADATAK:
--   Funkcija ispod ima namerno neiskoriscenu promenljivu (`unused_var`) koju
--   `lua_ls` oznacava kao warning/hint.
--   1. Skoci na dijagnostiku pomocu `]d` (i nazad `[d`).
--   2. Otvori opis greske u floatu sa `<leader>vd`.
--   3. Otvori Trouble za ovaj bafer: `<leader>qb` (zatvori ponovo sa `<leader>qb`).
--   4. Otvori Trouble simbol-stablo: `<leader>qs`.
--   5. Probaj `<leader>pd` (Snacks diagnostics picker) i `<leader>vca` (code action).
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local function nivo_27_diagnostics()
    local unused_var = "pogledaj me sa ]d i <leader>vd"
    return 200
end

-- ----------------------------------------------------------------------------
-- NIVO 28 / 33 — Formatiranje sa Conform (`stylua`)
-- Precica: <leader>f  (radi i u Visual modu samo za selektovani deo!)
-- Par: 4 poteza (`vaf<leader>f`)
-- ZADATAK: Stani u ruzno formatiranu funkciju ispod, selektuj je sa `vaf`
--          i formatiraj SAMO NJU pomocu `<leader>f`!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local function   nivo_28_messy(  a,b,   c )
local x=a+b
    if x>c then return   {a,b,c} end
return {c}
end

-- OCEKIVANI REZULTAT: Cisto formatirana Lua funkcija (uvucena po stylua pravilima).

-- ============================================================================
--  TIER 7: GIT, AI FLOATS & VIM GOLF BOSS NIVOI (Nivoi 29-33)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- NIVO 29 / 33 — Git Hunks (Gitsigns) + Lazygit + Fugitive
-- Precice: ]h / [h  |  <leader>ghp  |  <leader>ghb  |  <leader>ghs  |  <leader>ghr  |  <leader>gl  |  <leader>gs
-- ZADATAK (posle prvog commita ovog fajla ili u bilo kom tracked fajlu):
--   1. Izmeni liniju ispod, pa pritisni `<leader>ghp` (preview hunk).
--   2. Skaci izmedju izmena sa `]h` i `[h`.
--   3. Probaj `<leader>ghr` da resetujes samo taj jedan hunk (bez git checkout!).
--   4. Otvori Lazygit sa `<leader>gl` (`q` za izlaz) i Fugitive sa `<leader>gs`.
-- ----------------------------------------------------------------------------
local nivo_29_git_line = "izmeni me pa me vrati sa <leader>ghr"

-- ----------------------------------------------------------------------------
-- NIVO 30 / 33 — AI CLI Floating Terminali (Snacks.terminal)
-- Precice: <leader>ca (agy)  |  <leader>cg (grok)  |  <leader>co (opencode)  |  <leader>cx (codex)
--          <C-q> (sakrij float bez gasenja sesije!)
-- ZADATAK:
--   1. Otvori jedan od AI floatova, npr. `<leader>ca` ili `<leader>cg`.
--   2. Sakrij prozor sa `<C-q>` — sesija ostaje ziva u pozadini.
--   3. Opet pritisni isti shortcut — vracas se u istu sesiju!
--   4. Izadji iz AI CLI-ja (`/exit` ili `Ctrl+D`) da zatvoris sesiju.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NIVO 31 / 33 — BOSS 1: DevOps Config Cleanup (VIM GOLF — Par: 16 poteza)
-- Kombinuj: V + J/K, cs'", ds), ysiw", gcc, yi" + vi"<leader>p
-- ZADATAK: Preuredi `nivo_31_service` tako da se poklapa sa OCEKIVANIM
--          REZULTATOM (sto manje poteza!):
--   1. Zakomentarisi `legacy = true` (`gcc`).
--   2. Pomeri `name` na PRVO mesto (`V` + `K`).
--   3. Skini zagrade oko `(8080)` (`ds)`).
--   4. Zameni `'eu-central-1'` u `"eu-central-1"` (`cs'"`).
--   5. Kopiraj `"production"` (`yi"`) i pregazi `"dev"` i `"test"` sa `vi"<leader>p`.
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_31_env = "production"
local nivo_31_service = {
    legacy = true,
    port = (8080),
    name = "payments-api",
    region = 'eu-central-1',
    primary_env = "dev",
    fallback_env = "test",
}

-- OCEKIVANI REZULTAT:
-- local nivo_31_service = {
--     name = "payments-api",
--     -- legacy = true,
--     port = 8080,
--     region = "eu-central-1",
--     primary_env = "production",
--     fallback_env = "production",
-- }

-- ----------------------------------------------------------------------------
-- NIVO 32 / 33 — BOSS 2: Function Surgery (VIM GOLF — Par: 14 poteza)
-- Kombinuj: ]f, daa, cia, ds), cs'", vaf + <leader>f
-- ZADATAK:
--   1. Skoci u `nivo_32_build` sa `]f`.
--   2. Obrisi `dead_arg` parametar sa `daa`.
--   3. U `nivo_32_runner` obrisi `true` sa `daa`, pa zameni `'debug'` u `"release"`.
--   4. Skini visak zagrada oko `(target)` sa `ds)`.
--   5. Selektuj `nivo_32_build` sa `vaf` i sredi format sa `<leader>f`!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local function   nivo_32_build(target,  dead_arg,   mode)
return (target) .. ":" .. mode
end

local function nivo_32_runner()
    return nivo_32_build("linux-amd64", true, 'debug')
end

-- OCEKIVANI REZULTAT:
-- local function nivo_32_build(target, mode)
--     return target .. ":" .. mode
-- end
--
-- local function nivo_32_runner()
--     return nivo_32_build("linux-amd64", "release")
-- end

-- ----------------------------------------------------------------------------
-- NIVO 33 / 33 — FINAL BOSS: Full Primeagen + Folke Gauntlet (Par: 22 poteza)
-- Kombinuj SVE: ]f, daf, <leader>vrn, <leader>d, yi"+<leader>p, cs/ds/ys,
--               gcc, V+J/K, vaf+<leader>f, i na kraju proveri sa <leader>u!
-- ZADATAK:
--   1. Obrisi celu funkciju `nivo_33_trash` jednim potezom (`daf`).
--   2. U `nivo_33_deploy_cluster`, preimenuj lokalnu promenljivu `x_cfg` u
--      `cluster_cfg` koristeci LSP rename (`<leader>vrn`).
--   3. Obrisi liniju `local temp_junk = 999` u void registar (`<leader>dd`)
--      NAKON sto kopiras `"v2.5.0"` (`yi"`), pa sa `vi"<leader>p` zameni
--      `"v0.1.0"` u `"v2.5.0"`.
--   4. Promeni `'k8s'` -> `"k8s"` (`cs'"`) i skini zagrade sa `(3)` (`ds)`).
--   5. Zakomentarisi `dry_run = true` (`gcc`) i pomeri `version` na vrh tabele (`V`+`K`).
--   6. Formatiraj celu `nivo_33_deploy_cluster` sa `vaf<leader>f`.
--   7. Otvori `<leader>u` (Undotree) da vidis trag svog majstorstva!
-- ----------------------------------------------------------------------------
-- IGRAJ OVDE:
local nivo_33_latest = "v2.5.0"

local function nivo_33_trash()
    return "obrisi me celu sa daf!"
end

local function   nivo_33_deploy_cluster()
    local temp_junk = 999
    local x_cfg = {
        dry_run = true,
        engine = 'k8s',
        replicas = (3),
        version = "v0.1.0",
    }
    return x_cfg
end

-- OCEKIVANI REZULTAT:
-- (funkcija `nivo_33_trash` je obrisana)
-- local function nivo_33_deploy_cluster()
--     local cluster_cfg = {
--         version = "v2.5.0",
--         -- dry_run = true,
--         engine = "k8s",
--         replicas = 3,
--     }
--     return cluster_cfg
-- end

-- Izvoz da Lua zna da su lokalne promenljive/funkcije referencirane gde treba:
---@diagnostic disable: undefined-global
M.refs = {
    nivo_02_targets,
    nivo_03_cmd,
    nivo_04_pipeline,
    nivo_05_status,
    nivo_05_version,
    nivo_06_good_port,
    nivo_06_ports,
    nivo_07_source,
    nivo_07_junk,
    nivo_07_target,
    nivo_08_url,
    nivo_09_cfg,
    nivo_10_server,
    nivo_11_region,
    nivo_11_name,
    nivo_11_sum,
    nivo_12_a,
    nivo_12_b,
    nivo_12_c,
    nivo_13_num,
    nivo_13_deep,
    nivo_13_flag,
    nivo_14_node,
    nivo_15_alpha,
    nivo_15_beta,
    nivo_15_gamma,
    nivo_15_delta,
    nivo_16_bloated,
    nivo_17_keep_me,
    nivo_17_deprecated,
    nivo_18_call,
    nivo_19_second,
    nivo_19_first,
    nivo_21_demo,
    nivo_24_history,
    nivo_25_usage,
    nivo_26_rename_demo,
    nivo_27_diagnostics,
    nivo_28_messy,
    nivo_29_git_line,
    nivo_31_env,
    nivo_31_service,
    nivo_32_runner,
    nivo_33_latest,
    nivo_33_trash,
    nivo_33_deploy_cluster,
}
---@diagnostic enable: undefined-global

return M
