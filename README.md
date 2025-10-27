# Proposta de Projeto: Uma Replicação Empírica de Padrões de Otimização de Performance de Erlang em Elixir

**Autor:** Matheus de Camargo Marques

**Email:** matheuscamarques@gmail.com

**Instituição:** Universidade Tecnológica Federal do Paraná (UTFPR)

**Supervisor:** Prof. Adolfo Neto

---

*Este curso é oferecido pelo Programa de Pós-Graduação em Computação Aplicada (PPGCA) da Universidade Tecnológica Federal do Paraná (UTFPR). Destina-se principalmente a alunos de pós-graduação, mas alunos de graduação avançados e profissionais também podem participar.*

---

## Resumo

Este repositório contém o código-fonte para um projeto que implementa e valida empiricamente um conjunto de técnicas de otimização de desempenho, originalmente documentadas em um contexto Erlang, na linguagem de programação Elixir. O projeto consiste em uma pequena biblioteca experimental que serve como prova de conceito, demonstrando como padrões de refatoração específicos podem gerar melhorias significativas de desempenho.

## Como Replicar os Resultados

Para executar os benchmarks e validar os resultados apresentados, siga os passos abaixo:

```bash
# 1. Clone o repositório
git clone https://github.com/matheuscamarques/performance_patterns.git
cd performance_patterns

# 2. Instale as dependências
mix deps.get

# 3. Execute a suíte de benchmarks
mix run performance_benchmarks.exs
```

## Resultados dos Benchmarks

Os benchmarks foram executados em um processador AMD Ryzen 5 3500U com Elixir 1.19.0-rc.0 e Erlang 27.3.4.2. Os resultados abaixo representam a média de iterações por segundo (ips).

| Cenário | Implementação Otimizada (ips) | Implementação Ingênua (ips) | Melhoria |
| :--- | :--- | :--- | :--- |
| **Formatação de String** | 441.16 K | 261.79 K | **1.69x mais rápido** |
| **Achatamento de Lista** | 8.29 K | 4.60 K | **1.80x mais rápido** |
| **Processamento de Binário** | 7.51 K | 1.47 K | **5.09x mais rápido** |

*ips = iterações por segundo. Valores maiores são melhores.*

## Padrões Implementados

O código está organizado em módulos que demonstram cada padrão de otimização:

- **[`StringRefactoring`](lib/string_refactoring.ex):** Demonstra a otimização da formatação de strings substituindo a concatenação e o achatamento de listas (`List.flatten/1`) pela construção direta de `iolists`.

- **[`ListFlattening`](lib/list_flattening.ex):** Isola e demonstra o custo de `List.flatten/1` em comparação com o processamento nativo de `iolists` pela BEAM.

- **[`BinaryOptimizations`](lib/binary_optimizations.ex):** Mostra como o casamento de padrões no cabeçalho de funções recursivas permite que o compilador BEAM reutilize o contexto de casamento, evitando a criação de sub-binários e reduzindo a pressão sobre o Garbage Collector.

## Artigo Acadêmico

Para uma análise teórica aprofundada, incluindo a metodologia de profiling, o contexto acadêmico e a discussão detalhada dos resultados, por favor, consulte o artigo completo do projeto (`article.lex`).
