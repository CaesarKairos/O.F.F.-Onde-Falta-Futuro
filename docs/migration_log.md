# Registro da reorganização

## Mapeamento principal

| Caminho anterior | Caminho novo |
|---|---|
| `scenes/interface/Tela inicial` | `scenes/ui/main_menu` (arte em `assets/art/ui/main_menu`) |
| `scenes/interface/MENU` | `scenes/ui/settings` (arte em `assets/art/ui/settings`) |
| `scenes/interface/Pause` e arquivos `pause.*` da raiz | `assets/art/ui/pause`, `scenes/ui/pause` e `shaders` |
| `scenes/interface/fontes` | `assets/fonts` |
| `scenes/interface/tela de carregamento.*` | `scenes/ui/loading/loading_screen.*` |
| `scenes/levels/*` | `scenes/levels/chapter_01/*` |
| `scripts/actors/player.gd` | `scenes/actors/lyanna/player.gd` |
| `scenes/Shaders` e shaders dispersos | `shaders` |
| sprites da Cecília na raiz | `assets/art/characters/cecilia` |
| `assets/art/environment/props/gato_da_sorte.tscn` | `scenes/objects/environment/gato_da_sorte.tscn` |
| `scenes/quadro_do_pai.tscn` | `scenes/objects/environment/quadro_do_pai.tscn` |
| `assets/art/SimpleKeys/SimpleKeys` | `assets/third_party/simple_keys` |
| `Placeholder (Excluir)` | `assets/placeholders` |
| `installer/export_presets.cfg` | `export_presets.cfg` |
| `installer` | `builds/legacy` |
| `scripts/components.zip` | `docs/legacy/components.zip` |

O mapa completo arquivo a arquivo pode ser obtido com `git diff --summary --find-renames`. Os arquivos `.uid` e `.import` foram movidos com seus recursos. Referências textuais foram atualizadas sem alterar UIDs.

## Preservados para revisão

- `docs/legacy/components.zip`: contém uma versão antiga de `interactable.gd`; não foi removido.
- `assets/placeholders`: finalidade futura incerta e ao menos um placeholder possui referência estática.
- `builds/legacy`: executáveis e PCK anteriores foram preservados.
- Imagens parecidas não foram consolidadas apenas por nome; exigem revisão visual e das configurações de importação.

## Removidos

Dois arquivos `*.tmp` de cenas foram removidos após confirmação de que eram temporários do editor e estavam cobertos pelo `.gitignore` corrigido.

## Diagnóstico e validação

- A linha de base falhava ao carregar `translations.csv`. O projeto agora referencia diretamente os três recursos `.translation` gerados, preservando português, inglês e espanhol.
- A importação limpa revelou inferência ambígua em três variáveis e a ausência do Autoload `TimerManager`; foram aplicadas anotações de tipo mínimas e restaurado o Autoload.
- Importação normal, importação em cópia sem `.godot` e abertura headless da cena principal concluíram sem erros após as correções.
- `tools/validate_resources.gd` percorre cenas, recursos e shaders. Ele registra uma pendência preexistente em `cenario_1_quarto_02_legacy.tscn`, que aponta para `Cenário 1 - Quarto (02).jpg`, arquivo ausente já antes da migração.
- A exportação Windows foi tentada, mas os templates Godot 4.7.2 não estão instalados. Nenhuma build nova pôde ser validada.
- Fluxos que exigem interação gráfica (movimento, interações, escolhas, inventário, pause, configurações e save/load completo) ainda requerem teste manual.
