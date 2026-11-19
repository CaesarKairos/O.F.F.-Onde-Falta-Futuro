# Efeitos expressivos de diálogo

Este sistema acrescenta ritmo e entonação ao texto sem alterar o roteiro. A implementação foi aprovada, está integrada à branch `refactor/project-structure` e aceita normalmente falas sem marcação. Os diálogos existentes do capítulo 01 receberam direção artística em português, inglês e espanhol.

## Sintaxe

| Efeito | Sintaxe | Resultado |
|---|---|---|
| Destaque | `*palavra*` | Texto vermelho. |
| Onda | `~trecho~` | Movimento vertical suave e contínuo. |
| Impacto | `[impact]trecho[/impact]` | O trecho surge inteiro e ampliado uma vez. |
| Lento | `[slow]trecho[/slow]` | Revelação a 8 caracteres por segundo. |
| Rápido | `[fast]trecho[/fast]` | Revelação a 80 caracteres por segundo. |
| Pausa | `[pause=700]` | Interrompe a revelação por 700 ms sem mostrar a marcação. |
| Palavra por palavra | `[pop]trecho[/pop]` | Revela cada palavra inteira com uma entrada curta. |
| Sussurro | `[whisper]trecho[/whisper]` | Texto menor e com 60% de opacidade. |
| Typewriter | sem marcação | Revelação padrão a 30 caracteres por segundo. |

O vermelho oficial dos efeitos é `#b52d22`. O balão, a fonte VCR OSD Mono, os retratos e o posicionamento continuam sendo os mesmos.

## Combinações

As marcações podem ser aninhadas: `[impact]*ACORDA!*[/impact]`, `~*surpresa*~` e `[slow]*pai?*[/slow]`. Destaque, onda e sussurro combinam com os modos de revelação.

`slow` e `fast` alteram a mesma propriedade; quando forem aninhados, a marcação aberta por último vence. `impact` tem prioridade sobre `pop`, pois ambos determinam como o trecho entra. Os efeitos são encerrados no fechamento de sua marcação e nunca passam para a fala seguinte.

## Caracteres literais

Use uma barra invertida antes de um caractere de marcação: `\*`, `\~`, `\[` ou `\\`. Assim, `\*literal\*` exibe os asteriscos. Marcações desconhecidas ou incompletas são tratadas como texto seguro; não interrompem o diálogo.

## Comportamento do Espaço

Durante a revelação, Espaço mostra imediatamente a fala inteira e ignora pausas restantes. Um segundo toque avança. O mesmo toque nunca executa as duas ações. A onda continua ativa enquanto a fala permanece visível.

## Configuração

Os parâmetros ficam em `scripts/managers/dialogue_effects_manager.gd`: velocidades, cor, onda, impacto, pop e sussurro. Para comparar a apresentação expressiva com a original, altere `effects_enabled` para `false`. As marcações são removidas e o typewriter permanece ativo.

## Escrevendo novos diálogos

Comece pela intenção da fala. Use efeitos apenas onde ritmo ou entonação acrescentam significado. Marque cada idioma de acordo com sua própria estrutura, sem copiar posições mecanicamente. Nomes e informações importantes podem receber destaque; hesitação combina com `slow`; urgência com `fast`; uma interrupção forte com `impact`; ironia leve com onda; segredos com sussurro.

Para adicionar um efeito visual novo, implemente um `RichTextEffect` em `scenes/ui/dialogue/effects`, registre-o no `MessageUI` e acrescente a tag ao parser estruturado. Mantenha valores ajustáveis no manager e estado de reprodução na interface.
