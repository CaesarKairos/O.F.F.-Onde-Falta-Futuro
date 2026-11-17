# Estrutura do projeto

O projeto separa recursos importáveis (`assets`), cenas (`scenes`), sistemas globais (`scripts`), shaders, dados e documentação. A estrutura foi organizada sem alterar nós, sinais, chaves narrativas ou conteúdo do jogo.

## Diretórios

- `assets/art/characters`: sprites e retratos por personagem.
- `assets/art/environment`: fundos e objetos visuais dos cenários.
- `assets/art/ui`: imagens agrupadas pela interface que as utiliza.
- `assets/fonts`: fontes compartilhadas.
- `assets/third_party`: pacotes externos mantidos separados; preserve suas atribuições e estrutura interna.
- `assets/placeholders`: recursos provisórios ainda em uso ou com finalidade incerta.
- `scenes/actors`: cenas, scripts e recursos próprios de personagens.
- `scenes/components`: componentes reutilizáveis.
- `scenes/levels/chapter_01`: cenários e scripts do primeiro capítulo. Novos capítulos devem usar `chapter_02`, `chapter_03` etc.
- `scenes/objects/environment`: objetos de cenário; outros objetos reutilizáveis ficam em `scenes/objects`.
- `scenes/ui`: cenas e scripts de menu, configurações, carregamento, pause, diálogo, inventário, HUD e transições.
- `scripts/managers`: Autoloads e sistemas globais.
- `scripts/core`: constantes e utilitários compartilhados.
- `shaders`: shaders compartilhados.
- `data/dialogues`: JSON de diálogo por capítulo.
- `data/translations`: catálogo CSV e recursos de tradução.
- `builds`: saídas de exportação; `builds/legacy` preserva builds anteriores.
- `docs/legacy`: artefatos antigos preservados para análise.

## Convenções

Arquivos próprios novos usam `snake_case`, letras ASCII minúsculas e nomes descritivos. Não renomeie nós, métodos, sinais, grupos, flags, IDs de diálogo ou chaves de tradução apenas por estética. Conteúdo de terceiros pode manter os nomes fornecidos pelo autor.

## Movendo recursos com segurança

Prefira mover pelo FileSystem do editor Godot. Feche cenas afetadas, mova um grupo pequeno, aguarde a atualização das dependências e salve novamente. Confirme referências `res://`, `uid://`, `load`, `preload`, caminhos dinâmicos, Autoloads, traduções e preset de exportação. Mova também o arquivo `.uid` correspondente; arquivos `.import` versionados devem acompanhar a origem. Nunca edite o cache `.godot` manualmente.

Ao mover uma cena publicada, acrescente o caminho anterior a `LEGACY_SCENE_PATHS` em `SaveManager`, pois saves guardam `scene_path` literalmente. Depois execute importação limpa e carregue todas as cenas com o Godot real.
