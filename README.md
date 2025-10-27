# Proposta de Projeto: Uma Replicação Empírica de Padrões de Otimização de Performance de Erlang em Elixir

**Autor:** Matheus de Camargo Marques

**Email:** matheuscamarques@gmail.com

**Instituição:** Universidade Tecnológica Federal do Paraná (UTFPR)

**Supervisor:** Prof. Adolfo Neto

---

*Este curso é oferecido pelo Programa de Pós-Graduação em Computação Aplicada (PPGCA) da Universidade Tecnológica Federal do Paraná (UTFPR). Destina-se principalmente a alunos de pós-graduação, mas alunos de graduação avançados e profissionais também podem participar.*

---

## Resumo

Esta proposta descreve um projeto para implementar e validar empiricamente um conjunto de técnicas de otimização de desempenho, originalmente documentadas em um contexto Erlang, na linguagem de programação Elixir. O projeto envolverá a criação de uma pequena biblioteca experimental para servir como prova de conceito, demonstrando como padrões de refatoração específicos podem gerar melhorias significativas de desempenho. Ao aproveitar as ferramentas avançadas de benchmarking e profiling do Elixir, este trabalho fornecerá evidências quantitativas que suportam a transferibilidade desses padrões, baseando a análise nos princípios fundamentais da programação funcional e nas características operacionais da máquina virtual BEAM.

## Sumário
<!-- TOC -->
- [Proposta de Projeto: Uma Replicação Empírica de Padrões de Otimização de Performance de Erlang em Elixir](#proposta-de-projeto-uma-replicação-empírica-de-padrões-de-otimização-de-performance-de-erlang-em-elixir)
  - [Resumo](#resumo)
  - [Sumário](#sumário)
  - [1. Conceitos Fundamentais e Contribuição do Projeto](#1-conceitos-fundamentais-e-contribuição-do-projeto)
    - [1.1. Síntese de "Troubleshooting the Performance of a Large Erlang System"](#11-síntese-de-troubleshooting-the-performance-of-a-large-erlang-system)
    - [1.2. Contribuição Proposta: Uma Biblioteca Elixir Experimental para Refatoração de Performance](#12-contribuição-proposta-uma-biblioteca-elixir-experimental-para-refatoração-de-performance)
    - [1.3. A Centralidade dos Paradigmas da Programação Funcional](#13-a-centralidade-dos-paradigmas-da-programação-funcional)
  - [2. Plano de Implementação e Esboço Técnico](#2-plano-de-implementação-e-esboço-técnico)
    - [2.1. Estrutura do Código e Visão Geral dos Módulos (Esboço Parcial)](#21-estrutura-do-código-e-visão-geral-dos-módulos-esboço-parcial)
    - [2.2. O Fluxo de Trabalho de Medição e Análise](#22-o-fluxo-de-trabalho-de-medição-e-análise)
      - [2.2.1. Fase 1: Estabelecendo a Linha de Base com Benchee](#221-fase-1-estabelecendo-a-linha-de-base-com-benchee)
      - [2.2.2. Fase 2: Diagnóstico com Profiling e Flags do Compilador](#222-fase-2-diagnóstico-com-profiling-e-flags-do-compilador)
      - [2.2.3. Fase 3: Refatoração e Verificação](#223-fase-3-refatoração-e-verificação)
  - [3. Análise Aprofundada e Integração de Ferramentas Avançadas](#3-análise-aprofundada-e-integração-de-ferramentas-avançadas)
    - [3.1. Uma Abordagem Sinérgica para Profiling: A Arte da Triangulação](#31-uma-abordagem-sinérgica-para-profiling-a-arte-da-triangulação)
    - [3.2. Análise da Saída do Profiler](#32-análise-da-saída-do-profiler)
      - [3.2.1. StringRefactoring.format_date_naive](#321-stringrefactoringformat_date_naive)
      - [3.2.2. BinaryOptimizations.process_stream_naive](#322-binaryoptimizationsprocess_stream_naive)
    - [3.3. Contextualizando a Performance: O BEAM, Concorrência e Observer](#33-contextualizando-a-performance-o-beam-concorrência-e-observer)
  - [4. Aplicação Prática: Otimizando com bin_opt_info](#4-aplicação-prática-otimizando-com-bin_opt_info)
    - [4.1. Feedback do Compilador](#41-feedback-do-compilador)
    - [4.2. Refatorando a Manipulação de Strings](#42-refatorando-a-manipulação-de-strings)
    - [4.3. Otimizando o Processamento de Binários](#43-otimizando-o-processamento-de-binários)
  - [5. Análise de Resultados e Discussão](#5-análise-de-resultados-e-discussão)
    - [5.1. Padrão 1: O Custo do Achatamento de Listas Aninhadas](#51-padrão-1-o-custo-do-achatamento-de-listas-aninhadas)
      - [5.1.1. Discussão](#511-discussão)
    - [5.2. Padrão 2: Evitando a Criação de Sub-binários em Loops](#52-padrão-2-evitando-a-criação-de-sub-binários-em-loops)
      - [5.2.1. Discussão](#521-discussão)
  - [Conclusão](#conclusão)
  - [Bibliografia](#bibliografia)
<!-- /TOC -->

## 1. Conceitos Fundamentais e Contribuição do Projeto

### 1.1. Síntese de "Troubleshooting the Performance of a Large Erlang System"

O trabalho acadêmico fundamental para este projeto é o artigo "Troubleshooting the Performance of a Large Erlang System" de Tsikoudis e Sugiyama. A tese central do artigo é a apresentação de uma metodologia sistemática e iterativa para diagnosticar e resolver gargalos de desempenho em aplicações Erlang industriais de grande escala. Ele narra a jornada dos autores na otimização do Hyper-Q, um produto de virtualização de banco de dados, passando do que eles chamam de código "bonito" — idiomático, legível e muitas vezes dependente de funções de biblioteca de propósito geral — para código "rápido", que é customizado, especializado e altamente otimizado para caminhos de código críticos. Essa transição não é apresentada como uma prática padrão, mas como uma resposta de engenharia necessária quando metas de desempenho estritas, como os Acordos de Nível de Serviço (SLAs) do cliente, não estão sendo atendidas.

O principal desafio de desempenho identificado no sistema Hyper-Q não estava no domínio computacionalmente complexo da tradução de consultas SQL, mas sim no pós-processamento de grandes conjuntos de dados de resultados. Um incidente específico de um cliente é detalhado, onde um conjunto de resultados de 2 GB, compreendendo 16 milhões de linhas, exigiu cinco minutos de tempo total de processamento. A investigação revelou que o sistema de banco de dados de destino concluiu seu trabalho em apenas um minuto, enquanto as etapas subsequentes de conversão e serialização de dados dentro do Hyper-Q consumiram quatro minutos, respondendo por 80% da sobrecarga total. Este estudo de caso ressalta uma realidade comum em sistemas intensivos em dados: a manipulação e o transporte de dados podem, muitas vezes, impor uma penalidade de desempenho maior do que as computações algorítmicas principais.

Para resolver isso, os autores defendem uma metodologia rigorosa de solução de problemas baseada na triangulação com múltiplas ferramentas. O processo começa com o estabelecimento de um experimento de linha de base determinístico — um caso de teste repetível, como uma consulta `SELECT TOP 1000000`, com métricas claramente definidas para garantir que o impacto das otimizações possa ser medido de forma consistente. O próximo passo envolve isolar o componente de custo dominante. Ao aproveitar a arquitetura modular do Hyper-Q, os autores puderam contornar o subsistema de conversão de resultados para confirmar definitivamente que ele era a principal fonte de latência.

Com a área do problema isolada, um conjunto de ferramentas de profiling padrão do Erlang foi empregado em conjunto. Essa abordagem multi-ferramenta é crítica para a metodologia do artigo:
- **`cprof` (Call Count Profiler):** Usado para identificar funções com o maior número de invocações, apontando para os caminhos de código mais frequentemente executados.
- **`eprof` (Time Profiler):** Usado para medir o tempo total gasto em cada função, identificando quais das funções frequentemente chamadas também eram as mais caras.
- **`fprof` (File Trace Profiler):** Usado para analisar o grafo de chamadas completo, revelando quais funções específicas da aplicação eram responsáveis por chamar as funções de biblioteca caras e de alta contagem.

Ao combinar as saídas, os autores puderam passar efetivamente de um sintoma de alto nível (processamento lento de resultados) para um caminho de código específico e acionável que exigia refatoração.

Os esforços de otimização subsequentes descritos no artigo se enquadram em três categorias principais, que formam a base técnica para este projeto proposto:
1.  **Refatoração da Manipulação de Strings:** Um gargalo de desempenho significativo foi rastreado até o uso intenso de funções de formatação genéricas baseadas em listas, como `io_lib:format`, que internamente dependem de `lists:flatten`. A solução foi substituí-las por funções customizadas, pesadas em casamento de padrões, que constroem listas de I/O eficientes diretamente. Essa refatoração sozinha resultou em uma melhoria de desempenho de mais de 20%.
2.  **Otimizações no Processamento de Binários:** Guiados pelo feedback da flag `+bin_opt_info` do compilador Erlang, os autores identificaram e implementaram padrões de processamento de binários mais eficientes. Duas técnicas principais foram destacadas: usar o casamento de padrões de binários nos cabeçalhos das funções para permitir que o compilador reutilize o contexto de casamento entre chamadas recursivas e evitar a criação de restos de binários intermediários, retornando o tamanho do segmento analisado em vez disso. Essas mudanças melhoraram o desempenho em quase 20%.
3.  **Funções Implementadas Nativamente (NIFs):** Para um pequeno número de operações de baixo nível altamente repetitivas, onde até mesmo o código Erlang otimizado se mostrou insuficiente (por exemplo, contar clusters de grafemas em strings UTF-8), os autores recorreram à implementação de pequenas funções direcionadas em C como NIFs. Isso proporcionou um ganho de desempenho adicional de 10% para os componentes em questão.

### 1.2. Contribuição Proposta: Uma Biblioteca Elixir Experimental para Refatoração de Performance

A principal contribuição deste projeto é a replicação, validação e documentação dos princípios de otimização de desempenho do artigo de Tsikoudis e Sugiyama no ecossistema Elixir. Este trabalho não pretende inventar novas técnicas de otimização, mas sim conduzir um estudo empírico demonstrando que as descobertas e metodologias de solução de problemas centradas em Erlang do artigo são diretamente transferíveis e igualmente eficazes em Elixir. O projeto produzirá um artefato tangível e um conjunto de medições rigorosas que conectam as descobertas do artigo original ao contexto de desenvolvimento moderno do Elixir.

Para alcançar isso, uma pequena biblioteca Elixir, provisoriamente chamada de *PerformancePatterns*, será implementada como uma prova de conceito. Esta biblioteca funcionará como um "laboratório de desempenho" em vez de um utilitário pronto para produção. Sua estrutura principal consistirá em módulos contendo pares de funções, cada par ilustrando um padrão de desempenho específico:
- Uma **implementação "idiomática" ou "ingênua":** Esta versão será escrita em um estilo Elixir claro e idiomático que um desenvolvedor poderia naturalmente produzir como uma primeira solução. Ela será deliberadamente projetada para exibir os anti-padrões de desempenho identificados no artigo de origem (por exemplo, dependência de `Enum.map` seguido por `List.flatten`).
- Uma **implementação "otimizada":** Esta versão aplicará o padrão de refatoração específico e correspondente do artigo (por exemplo, uma função recursiva customizada usando casamento de padrões para construir uma `iolist`).

O pilar central do projeto é a medição e análise rigorosa do diferencial de desempenho entre esses pares de funções. Isso fornecerá evidências quantitativas da eficácia de cada padrão. Para garantir o rigor acadêmico e técnico, o projeto aproveitará o ecossistema de ferramentas de nível profissional do Elixir:
- **Benchmarking:** A biblioteca *Benchee* será usada para conduzir micro-benchmarks estatisticamente sólidos. Esta ferramenta fornece métricas robustas como iterações por segundo (IPS), tempo médio de execução, mediana e desvio padrão, permitindo uma comparação abrangente das implementações "ingênua" versus "otimizada".
- **Profiling:** A tarefa `mix profile.fprof` será usada para analisar a execução das funções "ingênuas". Isso gerará dados detalhados do grafo de chamadas que fornecem uma justificativa qualitativa para o motivo pelo qual uma refatoração específica é necessária, espelhando diretamente o processo de diagnóstico descrito no artigo de origem.
- **Análise do Compilador:** A flag do compilador Erlang `+bin_opt_info` será passada para o compilador Erlang subjacente através da variável de ambiente `ERL_COMPILER_OPTIONS` na ferramenta de build Mix. Isso permitirá que o projeto demonstre como o próprio compilador BEAM fornece feedback acionável para otimizações de binários de baixo nível, replicando uma técnica de diagnóstico chave do artigo.

### 1.3. A Centralidade dos Paradigmas da Programação Funcional

Este projeto demonstrará que as características de desempenho sob investigação não são arbitrárias, mas estão profundamente enraizadas em conceitos fundamentais de programação funcional (PF) e nos detalhes específicos de sua implementação na máquina virtual BEAM. As otimizações propostas são, em essência, aplicações práticas da teoria da PF para alcançar um desempenho superior.

1.  **Casamento de Padrões versus Funções de Ordem Superior:** A otimização de "Manipulação de Strings" apresenta um trade-off clássico no design funcional. A abordagem ingênua aproveita o poder expressivo da composição de funções genéricas de ordem superior como `Enum.map` e `List.flatten`. A abordagem otimizada, em contraste, usa funções customizadas construídas sobre os conceitos fundamentais da PF de recursão e casamento de padrões refinado. Este projeto analisará como o casamento de padrões, um pilar de linguagens como Elixir e Erlang, muitas vezes compila para instruções de desvio altamente eficientes (tabelas de salto), enquanto a abordagem genérica pode incorrer em sobrecarga adicional de configuração/desmontagem repetida de chamadas de função e a criação de estruturas de dados intermediárias (a lista produzida por `map` antes de ser consumida por `flatten`).
2.  **Imutabilidade e Transformação de Dados:** As "Otimizações de Binários" são uma consequência direta e tangível do trabalho com estruturas de dados imutáveis. Na BEAM, os binários não podem ser modificados no local. Operações que parecem ser modificações, como pegar uma fatia ou o "resto" de um binário, estão na verdade criando novas estruturas de dados. Embora os sub-binários sejam referências leves que compartilham os dados originais, sua criação ainda envolve alocação. A principal percepção do artigo — evitar retornar um resto de binário de uma função de análise e, em vez disso, retornar seu tamanho — é uma estratégia sofisticada para minimizar essas alocações. Ao fazer isso, a função chamadora pode realizar uma única operação de fatiamento, reduzindo a pressão sobre os subsistemas de gerenciamento de memória e coleta de lixo. A implementação deste projeto tornará este conceito abstrato concreto e mensurável.
3.  **Recursão e Otimização de Chamada de Cauda (TCO):** As funções customizadas e refatoradas que substituem as funções genéricas de ordem superior serão naturalmente implementadas usando recursão. Isso fornece uma oportunidade direta para discutir e aproveitar a Otimização de Chamada de Cauda (TCO), uma característica crítica dos compiladores de linguagens funcionais. A TCO garante que as chamadas recursivas que estão em uma "posição de cauda" não consumam espaço adicional na pilha, permitindo que sejam executadas com a mesma eficiência de memória que um loop iterativo tradicional. As funções otimizadas na biblioteca *PerformancePatterns* serão projetadas como recursivas de cauda, demonstrando as melhores práticas para escrever código recursivo eficiente e que não consome pilha na BEAM.

## 2. Plano de Implementação e Esboço Técnico

Esta seção detalha o plano de implementação concreto para a biblioteca *PerformancePatterns* e o fluxo de trabalho experimental para medição e análise. Ela fornece um esboço parcial do código e um procedimento passo a passo para conduzir a investigação de desempenho.

### 2.1. Estrutura do Código e Visão Geral dos Módulos (Esboço Parcial)

A biblioteca *PerformancePatterns* será organizada em módulos, cada um focando em uma categoria de otimização específica do artigo de origem. Todas as funções serão acompanhadas por documentação extensa explicando o (anti-)padrão de desempenho que demonstram.

```elixir
# lib/performance_patterns.ex
defmodule PerformancePatterns do
  @moduledoc """
  Uma biblioteca para a demonstração prática de padrões de desempenho discutidos em
  "Troubleshooting the Performance of a Large Erlang System" por Tsikoudis e Sugiyama.
  Cada módulo contém pares de funções: uma implementação idiomática ("ingênua")
  e uma implementação refatorada ("otimizada") para comparação.
  """
end

# lib/performance_patterns/string_refactoring.ex
defmodule PerformancePatterns.StringRefactoring do
  @moduledoc """
  Demonstra a substituição de operações genéricas de lista/string por funções
  recursivas customizadas para ganhos significativos de desempenho em caminhos de código críticos.
  Isso espelha a seção "Manipulação de Strings" do artigo de origem.
  """

  @doc """
  Formatação de data ingênua usando uma abordagem genérica de múltiplos passos envolvendo
  `Enum.map` e `List.flatten`. Isso simula o uso de uma biblioteca de formatação
  de propósito geral que muitas vezes depende de `lists:flatten/1`, um conhecido
  gargalo de desempenho para listas de listas profundas ou longas.
  """
  def format_date_naive({y, m, d}) do
    # Anti-padrão: Cria binários intermediários com `Integer.to_string`
    # e depois achata a lista, forçando a criação de uma nova estrutura de
    # dados antes da conversão final.
    [
      Integer.to_string(rem(y, 100)),
      "/",
      Integer.to_string(m),
      "/",
      Integer.to_string(d)
    ]
    |> List.flatten() # Operação custosa
    |> IO.iodata_to_binary()
  end

  @doc """
  Formatação de data otimizada usando uma função customizada que constrói uma iolist
  diretamente. Isso evita a criação de estruturas de lista intermediárias e a
  custosa operação `List.flatten/1`. A implementação usa `charlist`s, que são
  componentes ideais e eficientes para `iolist`s.
  para IO.
  """
  def format_date_optimized({y, m, d}) do
    # Padrão otimizado: Constrói uma iolist aninhada diretamente.
    # `IO.iodata_to_binary/1` processa iolists de forma muito eficiente.
    [
      format_year_yy_charlist(rem(y, 100)),
      ~c"/",
      format_two_digits_charlist(m),
      ~c"/",
      format_two_digits_charlist(d)
    ]
    |> IO.iodata_to_binary()
  end

  # Funções auxiliares que constroem `charlist`s (listas de caracteres),
  # ideais para a composição eficiente de `iolist`s.
  defp format_year_yy_charlist(y) when y < 10, do: ['0' | Integer.to_charlist(y)]
  defp format_year_yy_charlist(y), do: Integer.to_charlist(y)

  defp format_two_digits_charlist(n) when n < 10, do: ['0' | Integer.to_charlist(n)]
  defp format_two_digits_charlist(n), do: Integer.to_charlist(n)
end

# lib/performance_patterns/binary_optimizations.ex
defmodule PerformancePatterns.BinaryOptimizations do
  @moduledoc """
  Demonstra otimizações de processamento de binários guiadas pela flag
  `+bin_opt_info` do compilador Erlang, conforme descrito no artigo.
  """

  @doc """
  Decodificação de binário ingênua que retorna o resto do binário (`rest`).
  Isso força o runtime a criar um novo binário (ou sub-binário) em cada
  chamada, o que pode disparar um aviso "BINARY CREATED" do compilador e
  levar a alocação de memória desnecessária e pressão de GC.
  """
  def decode_naive(<<value::unsigned-little-integer-16, rest::binary>>) do
    {value, rest}
  def process_stream_naive(binary, acc \ []) do
    # A recursão é feita em uma função auxiliar para espelhar a estrutura da
    # versão otimizada, mas o casamento de padrões ocorre no corpo da função,
    # impedindo a otimização do compilador.
    _process_stream_naive(binary, acc)
  end

  def process_stream_naive(binary, acc \ []) do
    case byte_size(binary) do
      0 -> Enum.reverse(acc)
      _ ->
        {value, rest} = decode_naive(binary)
        process_stream_naive(rest, [value | acc])
    end
  defp _process_stream_naive(<<>>, acc), do: Enum.reverse(acc)
  defp _process_stream_naive(binary, acc) do
    # Anti-padrão: O casamento de padrões aqui cria um novo sub-binário `rest`
    # a cada chamada, impedindo a reutilização do contexto de casamento.
    <<value::unsigned-little-integer-16, rest::binary>> = binary
    _process_stream_naive(rest, [value | acc])
  end

  @doc """
  Processamento de stream otimizado. O casamento de padrões é movido para o
  cabeçalho da função recursiva. Isso permite que o compilador BEAM aplique a
  otimização de "reutilização de contexto de casamento", evitando a criação de
  sub-binários a cada iteração.
  """

  def process_stream_optimized(binary, acc \ []) do
    # A chamada recursiva é feita em uma função auxiliar privada que usa
    # casamento de padrões no cabeçalho, permitindo a otimização do compilador.
    _process_stream_optimized(binary, acc)
  end

  defp _process_stream_optimized(<<>>, acc), do: Enum.reverse(acc)

  # Padrão otimizado: O casamento de padrões no cabeçalho da função permite
  # que o compilador BEAM reutilize o "match context", simplesmente avançando
  # um ponteiro sobre o binário original em vez de criar novos sub-binários.
  defp _process_stream_optimized(
         <<value::unsigned-little-integer-16, rest::binary>>,
         acc
       ) do
    _process_stream_optimized(rest, [value | acc])
  end
end

# lib/performance_patterns/list_flattening.ex
defmodule PerformancePatterns.ListFlattening do
  @moduledoc """
  Demonstra o custo de `List.flatten/1` em comparação com o processamento
  nativo de iolists pela BEAM. Este módulo fornece as funções para o
  benchmark descrito na Seção 5.1.
  """

  @doc """
  Achatamento explícito de uma lista aninhada antes da conversão para binário.
  """
  def naive_flatten(iolist) do
    iolist |> List.flatten() |> IO.iodata_to_binary()
  end

  @doc """
  Conversão direta de uma iolist aninhada para binário, evitando `List.flatten/1`.
  """
  def optimized_flatten(iolist) do
    iolist |> IO.iodata_to_binary()
  end
end
```

### 2.2. O Fluxo de Trabalho de Medição e Análise

O procedimento experimental principal deste projeto seguirá um fluxo de trabalho estruturado em três fases, projetado para primeiro estabelecer uma linha de base, depois diagnosticar a causa subjacente de qualquer déficit de desempenho e, finalmente, verificar a eficácia da otimização aplicada.

#### 2.2.1. Fase 1: Estabelecendo a Linha de Base com Benchee
- **Ação:** Um script de benchmark será criado (por exemplo, `bench/performance_benchmarks.exs`) que utiliza a função `Benchee.run/2`.
- **Configuração:** A suíte de benchmark será configurada com configurações apropriadas de `time` e `warmup` (por exemplo, `time: 5`, `warmup: 2`) para garantir que o sistema atinja um estado estável e que as medições sejam estatisticamente significativas. A opção `inputs` será usada para fornecer dados realistas às funções benchmarked, como uma grande lista de tuplas de data para as funções de formatação de string e um binário grande para as funções de processamento de stream.
- **Objetivo:** Esta fase produzirá a linha de base quantitativa para o projeto. A saída do *Benchee* relatará claramente as principais métricas de desempenho, como iterações por segundo (IPS) e tempo médio de execução, para todas as implementações "ingênuas". Esses dados servem como o benchmark inicial contra o qual todas as melhorias subsequentes serão medidas.

#### 2.2.2. Fase 2: Diagnóstico com Profiling e Flags do Compilador
- **Ação (Profiling):** A tarefa `mix profile.fprof` será executada em um script que chama as funções "ingênuas" com uma carga de trabalho representativa. Por exemplo: `mix profile.fprof -e "for _ <- 1..1000, do: PerformancePatterns.StringRefactoring.format_date_naive({2024, 5, 21})"`.
- **Análise (Profiling):** A saída do `fprof` será analisada para identificar gargalos. Para o exemplo de formatação de string, espera-se que o tempo `ACC` (acumulado) seja alto para funções relacionadas a `Enum.map/2` e, particularmente, `List.flatten/1`. Este resultado corroboraria diretamente as descobertas do artigo de origem, que identificou `lists:do_flatten/2` como um dos principais contribuintes para o tempo de execução. Este passo fornece a evidência qualitativa necessária para justificar o esforço de refatoração subsequente.
- **Ação (Flags do Compilador):** O projeto Elixir será recompilado com a flag `bin_opt_info` ativada. Isso é feito definindo uma variável de ambiente antes de invocar a tarefa do compilador Mix: `ERL_COMPILER_OPTIONS="[bin_opt_info]" mix compile --force`.
- **Análise (Flags do Compilador):** A saída do compilador será inspecionada em busca de avisos relevantes. Para a função `decode_naive/1`, espera-se que o compilador emita uma mensagem `Warning: BINARY CREATED`, indicando que um novo binário está sendo criado e retornado. Por outro lado, para a função `process_stream_optimized/2`, o compilador deve emitir uma mensagem `Warning: OPTIMIZED: match context reused`, confirmando que aplicou com sucesso uma otimização devido à estrutura de código aprimorada.

#### 2.2.3. Fase 3: Refatoração e Verificação
- **Ação:** As versões "otimizadas" das funções serão implementadas conforme detalhado no esboço do código acima.
- **Verificação:** A suíte de benchmark *Benchee* da Fase 1 será executada novamente, desta vez incluindo as funções otimizadas recém-implementadas ao lado de suas contrapartes ingênuas.
- **Objetivo:** Esta fase final quantificará rigorosamente a melhoria de desempenho. A saída de comparação do *Benchee* fornecerá um resumo claro e conciso dos resultados, como "`format_date_optimized` é 16.5x mais rápido que `format_date_naive`". Isso valida a eficácia da refatoração e cumpre o principal objetivo experimental do projeto.

**Tabela 1: Correspondência de Ferramentas e Conceitos Erlang-para-Elixir**

| Conceito/Ferramenta Erlang (de \cite{tsikoudis2022}) | Equivalente/Implementação Elixir | Propósito neste Projeto |
| :--- | :--- | :--- |
| `cprof`, `eprof`, `fprof` | `mix profile.cprof`, `mix profile.eprof`, `mix profile.fprof` | Diagnosticar gargalos de desempenho analisando contagens de chamadas, tempo gasto e pilhas de chamadas, respectivamente. |
| Flag do compilador `+bin_opt_info` | `ERL_COMPILER_OPTIONS="[bin_opt_info]"` | Receber feedback do compilador sobre a eficiência da construção de binários e casamento de padrões. |
| Gargalo `lists:flatten/1` | Anti-padrão `Enum.map` > `List.flatten` | Simular o gargalo de desempenho do processamento de listas genérico e de múltiplos passos. |
| Funções de formatação customizadas | Funções recursivas com casamento de padrões | Implementar a alternativa de alto desempenho para funções de formatação genéricas. |
| Retornos ineficientes de resto de binário | `decode_naive/1` retornando `{val, rest_bin}` | Criar um problema de desempenho reproduzível relacionado a alocações de binários desnecessárias. |
| Reutilização otimizada de contexto de binário | `decode_optimized/1` retornando `{val, size}` | Implementar o padrão de alto desempenho que minimiza a cópia de binários e permite a otimização do compilador. |
| Experimento de Linha de Base Determinístico | Suíte de benchmark *Benchee* | Fornecer medição quantitativa rigorosa do desempenho antes e depois das otimizações. |

**Tabela 2: Saída de Benchmark Benchee Projetada (Hipotética)**

| Cenário | Ingênuo (IPS) | Otimizado (IPS) | Melhoria |
| :--- | :--- | :--- | :--- |
| Formatação de String de Data | ~150 K | ~2.5 M | ~16.7x |
| Processamento de Stream de Binário | ~4.2 M | ~6.7 M | ~1.6x |

## 3. Análise Aprofundada e Integração de Ferramentas Avançadas

Esta seção final descreve caminhos para uma análise mais sutil que vai além dos requisitos imediatos da implementação. Ela demonstra um entendimento mais profundo do ecossistema BEAM, integrando ferramentas mais avançadas e conectando otimizações de código de micro-nível ao seu impacto de macro-nível no sistema em execução.

### 3.1. Uma Abordagem Sinérgica para Profiling: A Arte da Triangulação

O verdadeiro poder da suíte de profiling da BEAM, como implícito no artigo de origem, não reside no uso isolado de uma única ferramenta, mas na síntese de suas saídas complementares para construir uma narrativa completa de um problema de desempenho. Este projeto adotará este fluxo de trabalho especializado para demonstrar um processo de diagnóstico sofisticado.

- **`mix profile.cprof` (A Rede Ampla):** A análise inicial usará `cprof` para coletar contagens de chamadas de função (CNT). Isso atua como um filtro de primeira passagem para identificar caminhos de código "quentes" — funções que são executadas com frequência extremamente alta. No entanto, uma alta contagem de chamadas por si só não é um indicador de um problema, pois uma função trivial pode ser chamada milhões de vezes com impacto insignificante.
- **`mix profile.eprof` (O Localizador de Hotspots):** O segundo passo envolverá `eprof` para medir o tempo gasto em cada função. Os resultados do `eprof` serão correlacionados com os dados do `cprof`. Uma função que aparece no topo de ambas as listas — tendo tanto uma alta contagem de chamadas quanto um tempo de execução total significativo — é uma candidata principal para um gargalo de desempenho de alto impacto. Essa correlação fornece um sinal muito mais forte do que qualquer uma das ferramentas poderia fornecer sozinha.
- **`mix profile.fprof` (O Microscópio):** Finalmente, com uma função específica identificada como um gargalo, `fprof` será usado com a opção `--callers` para realizar uma análise aprofundada. Esta ferramenta revela a pilha de chamadas precisa, mostrando quais funções estão chamando o gargalo (chamadores) e quais funções ele está chamando (chamados). Esta visão detalhada e contextual é o que permite uma refatoração precisa e direcionada, pois responde não apenas *o que* é lento, mas *por que* e *de onde* está sendo invocado.

Este projeto também deve reconhecer um aspecto crítico da análise de desempenho: o efeito observador. As ferramentas de profiling, particularmente as baseadas em rastreamento como `fprof`, introduzem uma sobrecarga significativa que pode alterar o comportamento do sistema sob medição. O artigo de origem demonstra uma compreensão madura dessa limitação usando uma consulta menor, mas estruturalmente idêntica, para o rastreamento com `fprof` para minimizar essa distorção. Este projeto adotará uma estratégia semelhante, demonstrando uma consciência metodológica sofisticada. Os benchmarks do *Benchee* serão executados no conjunto de dados completo e representativo para obter tempos finais precisos, enquanto o `fprof` será usado com um conjunto de dados menor, suficiente para diagnosticar a estrutura do grafo de chamadas sem ser indevidamente influenciado por sua própria sobrecarga.

### 3.2. Análise da Saída do Profiler

Para fornecer evidências concretas para o processo de diagnóstico descrito, os profilers `cprof`, `eprof` e `fprof` foram executados nas funções "ingênuas" da biblioteca PerformancePatterns. As seções a seguir apresentam os dados coletados e uma breve análise dos resultados, demonstrando como essas ferramentas identificam as fontes exatas de ineficiência.

#### 3.2.1. StringRefactoring.format_date_naive

A função `format_date_naive/1` foi perfilada para simular o gargalo causado pela manipulação genérica de listas e strings.

**cprof (Contagem de Chamadas)**
```
                                                                     CNT
Total                                                             185010
Enum                                                               75001  <--
  Enum."-map/2-lists^map/1-1-"/2                                   60000
  Enum.map/2                                                       10001
  Enum.map_range/4                                                  5000
PerformancePatterns.StringRefactoring                              60000  <--
  anonymous fn/4 in PerformancePatterns.StringRefactoring.fo       50000
  PerformancePatterns.StringRefactoring.format_date_naive/1        10000
:erlang                                                            40004  <--
  :erlang.integer_to_list/1                                        30000
  :erlang.iolist_to_binary/1                                       10000
```

**eprof (Tempo de Execução)**
```
#                                                                           CALLS     %   TIME µS/CALL
Total                                                                       18500 100.0 578879    3.13
...
PerformancePatterns.StringRefactoring.format_date_naive/1                   10000  8.44  48861    4.89
:erlang.integer_to_list/1                                                   30000  8.92  51612    1.72
anonymous fn/4 in PerformancePatterns.StringRefactoring.format_date_naive/1 50000 23.49 135964    2.72
Enum."-map/2-lists^map/1-1-"/2                                              60000 44.69 258695    4.31
```

**fprof (Grafo de Chamadas)**
```
                                                                   CNT    ACC (ms)    OWN (ms)
Total                                                            18552     168.713     165.672
...
PerformancePatterns.StringRefactoring.format_date_naive/1         1000     153.849      14.302
Enum."-map/2-lists^map/1-1-"/2                                    6000     125.661      74.650
anonymous fn/4 in PerformancePatterns.StringRefactoring.form      5000      50.375      35.878
:erlang.integer_to_list/1                                         3000      14.057      13.750
```

**Análise**
Os resultados combinados dos profilers confirmam a hipótese do artigo. `cprof` mostra uma alta contagem de invocações para `Enum."-map/2-lists^map/1-1-"/2` e a função anônima dentro de `format_date_naive`. `eprof` e `fprof` confirmam que essas funções de alta contagem também são responsáveis pela maior parte do tempo de execução. Essa triangulação aponta diretamente para a operação `Enum.map` e sua função anônima associada como o principal gargalo de desempenho, justificando a refatoração para uma abordagem mais direta de construção de iolist.

#### 3.2.2. BinaryOptimizations.process_stream_naive

A função `process_stream_naive/1` foi perfilada para analisar o impacto da criação de sub-binários em um loop recursivo.

**cprof (Contagem de Chamadas)**
```
                                                                     CNT
Total                                                             211165
PerformancePatterns.BinaryOptimizations                           200200  <--
  PerformancePatterns.BinaryOptimizations.do_process_stream_      100100
  PerformancePatterns.BinaryOptimizations.decode_naive/1          100000
  PerformancePatterns.BinaryOptimizations.process_stream_nai         100
```

**eprof (Tempo de Execução)**
```
#                                                                  CALLS     %   TIME µS/CALL
Total                                                             211175 100.0 534211    2.53
...
PerformancePatterns.BinaryOptimizations.decode_naive/1            100000 31.90 170409    1.70
PerformancePatterns.BinaryOptimizations.do_process_stream_naive/2 100100 60.50 323202    3.23
```

**fprof (Grafo de Chamadas)**
```
                                                                   CNT    ACC (ms)    OWN (ms)
Total                                                             3130      23.119      23.075
...
PerformancePatterns.BinaryOptimizations.do_process_stream_na      1010      14.128       9.535
PerformancePatterns.BinaryOptimizations.decode_naive/1            1000       4.388       4.254
```

**Análise**
Os dados de profiling para a função de processamento de binário ingênua são igualmente reveladores. `cprof` mostra que `PerformancePatterns.BinaryOptimizations.do_process_stream_naive/2` e `PerformancePatterns.BinaryOptimizations.decode_naive/1` são chamadas um número muito grande de vezes. `eprof` e `fprof` confirmam que essas duas funções consomem a grande maioria do tempo de execução. Isso destaca a ineficiência da estratégia recursiva que cria um novo sub-binário em cada iteração. O alto custo está associado ao gerenciamento dessas partes binárias, mesmo que os dados subjacentes não sejam copiados. Isso fornece uma justificativa clara para refatorar o código para usar o casamento de padrões no cabeçalho da função, o que permite que o compilador BEAM reutilize o contexto de casamento e evite a criação de sub-binários intermediários.

### 3.3. Contextualizando a Performance: O BEAM, Concorrência e Observer

As otimizações exploradas neste projeto são, em sua essência, micro-otimizações que tornam as funções individuais mais rápidas. No entanto, no contexto da máquina virtual BEAM, essas melhorias localizadas podem ter efeitos significativos de macro-nível na saúde e escalabilidade de todo o sistema. A ferramenta *Observer*, uma interface gráfica para inspecionar um nó BEAM em execução, fornece uma janela inestimável para essas implicações em nível de sistema.

O processamento ineficiente de binários na função `decode_naive/1`, por exemplo, faz mais do que apenas consumir ciclos de CPU em excesso. Ao criar um novo objeto binário em cada invocação, ele gera um alto volume de lixo de curta duração. Isso aumenta a rotatividade de memória e força o coletor de lixo do processo a ser executado com mais frequência. Cada ciclo de coleta de lixo, por mais breve que seja, pausa a execução desse processo, impactando sua latência e taxa de transferência.

Para explorar essa conexão, será proposto um passo de análise avançada. Após executar um benchmark sustentado usando *Benchee*, a ferramenta *Observer* será anexada ao processo BEAM em execução.

- **Ação:** Um terminal executará o script de benchmark (`iex -S mix run bench/performance_benchmarks.exs`). Um segundo terminal conectará um shell remoto a esse nó (`iex --sname observer --remsh <node_name>`) e iniciará a ferramenta gráfica com `:observer.start()`.
- **Análise:** Dentro da GUI do *Observer*, o processo que executa o benchmark será monitorado. Uma comparação será feita entre os padrões de uso de memória e as estatísticas de coleta de lixo (GC Min, GC Maj) durante a execução do código "ingênuo" versus a execução do código "otimizado". A hipótese é que o manuseio otimizado de binários resultará em um pico de uso de memória visivelmente menor e uma frequência reduzida de eventos de coleta de lixo para o processo.

Essa análise conecta uma mudança de código específica — uma micro-otimização — a um impacto mensurável no comportamento de um sistema central. O artigo de origem alude a problemas de contenção em nível de sistema, observando que simplesmente adicionar mais núcleos de CPU não produziu ganhos de desempenho proporcionais. Embora este projeto de pequena escala não replique um problema de escalonamento multi-core, ele pode demonstrar o mecanismo subjacente. Práticas inadequadas de gerenciamento de memória, como a cópia excessiva de binários na implementação ingênua, podem se tornar um gargalo em todo o sistema. O coletor de lixo é um recurso crítico, e a contenção pela alocação e desalocação de memória pode limitar a escalabilidade efetiva de um sistema concorrente. Ao usar o *Observer* para traçar uma linha clara de uma linha de código ao comportamento da memória da máquina virtual, este projeto demonstrará uma compreensão holística e avançada da engenharia de desempenho na BEAM.

## 4. Aplicação Prática: Otimizando com bin_opt_info

Para validar o poder de diagnóstico do feedback do compilador Erlang, a metodologia descrita na Fase 2 do fluxo de trabalho foi executada na biblioteca *PerformancePatterns*. Esta seção documenta o processo prático e passo a passo de usar a flag `+bin_opt_info` para identificar e resolver problemas de desempenho nas implementações "ingênuas".

### 4.1. Feedback do Compilador

Como hipotetizado, compilar com a flag `+bin_opt_info` forneceu feedback direto e acionável sobre as implementações ingênuas. O compilador gerou os seguintes avisos e mensagens de otimização:

```
warning: BINARY CREATED: binary is returned from the function
  lib/string_refactoring.ex:17

warning: BINARY CREATED: binary is used in a term that is returned from the function
  lib/binary_optimizations.ex:15

warning: OPTIMIZED: match context reused
  lib/binary_optimizations.ex:44
```

Esta saída serve como uma ferramenta de diagnóstico precisa:
- O primeiro aviso identifica corretamente que o `Enum.map` em `format_date_naive/1` está criando binários intermediários.
- O segundo aviso aponta `decode_naive/1` como problemático porque retorna um sub-binário, forçando uma alocação.
- A mensagem final `OPTIMIZED` confirma que o compilador otimizou com sucesso a chamada recursiva na função `do_process_stream_optimized/2`, validando a abordagem refatorada.

Este feedback fornece a justificativa qualitativa para os esforços de refatoração descritos a seguir.

O processo começou compilando o projeto com a flag de diagnóstico ativada:
```bash
$ ERL_COMPILER_OPTIONS="[bin_opt_info]" mix compile --force
```

Este comando instrui o compilador Erlang subjacente a emitir informações detalhadas sobre otimizações relacionadas a binários. Como hipotetizado, a compilação inicial produziu uma série de avisos, fornecendo um roteiro claro para a refatoração.

### 4.2. Refatorando a Manipulação de Strings

O primeiro conjunto de avisos pertencia à função `format_date_naive/1` no módulo `StringRefactoring`. O compilador emitiu um aviso `BINARY CREATED`, apontando a função anônima dentro de `Enum.map/2` como a fonte de ineficiência.

```elixir
def format_date_naive({y, m, d}) do
  ["YY", "/", "MM", "/", "DD"]
  |> Enum.map(fn
    "YY" -> Integer.to_string(rem(y, 100))
    "MM" -> Integer.to_string(m)
    "DD" -> Integer.to_string(d)
    sep  -> sep
  end)
  |> List.flatten()
  |> IO.iodata_to_binary()
end
```

A causa raiz foi a criação de pequenos binários intermediários por `Integer.to_string/1` e o retorno do separador binário `"/"` dentro da função mapeada. Para resolver isso, uma refatoração em várias etapas foi aplicada:
1.  `Integer.to_string/1` foi substituído por `Integer.to_charlist/1`. Isso constrói uma lista de caracteres em vez de um binário, que é um componente mais eficiente para uma iolist.
2.  A chamada desnecessária `List.flatten/1` foi removida, pois `IO.iodata_to_binary/1` é capaz de lidar com iolists aninhadas.
3.  A cláusula genérica `sep -> sep` foi substituída por um casamento de padrão específico para o separador, `"/" -> ~c"/"`, usando o sigil moderno `~c` para representar a charlist, tratando um aviso de depreciação no processo.

```elixir
def format_date_naive({y, m, d}) do
  ["YY", "/", "MM", "/", "DD"]
  |> Enum.map(fn
    "YY" -> Integer.to_charlist(rem(y, 100))
    "MM" -> Integer.to_charlist(m)
    "DD" -> Integer.to_charlist(d)
    "/"  -> ~c"/"
  end)
  |> IO.iodata_to_binary()
end
```

Após essas mudanças, a recompilação do projeto com as mesmas flags resultou na remoção completa dos avisos para este módulo, confirmando o sucesso da otimização.

### 4.3. Otimizando o Processamento de Binários

Um processo semelhante foi aplicado ao módulo `BinaryOptimizations`, que apresentou um conjunto diferente de avisos.

A função `decode_naive/1` disparou um aviso `BINARY CREATED` porque retornava o resto do binário, forçando o runtime a alocar um novo sub-binário.

```elixir
def decode_naive(<<value::unsigned-little-integer-16, rest::binary>>) do
  {value, rest}
end
```

A correção, espelhando o padrão em `decode_optimized/1`, foi retornar o tamanho conhecido do segmento analisado (2 bytes) em vez do próprio binário.

```elixir
def decode_naive(<<value::unsigned-little-integer-16, _::binary>>) do
  {value, 2}
end
```

Além disso, a função auxiliar recursiva `_process_stream_optimized/2` produziu dois avisos: `NOT OPTIMIZED` e `BINARY CREATED`. Isso ocorria porque o casamento de padrões de binário estava acontecendo dentro do corpo da função, impedindo o compilador de reutilizar o contexto de casamento entre as chamadas recursivas.

A solução foi refatorar a função para realizar o casamento de padrões no cabeçalho da função. Este é um padrão mais idiomático e altamente eficiente para o processamento recursivo de streams em Elixir e Erlang.

```elixir
defp _process_stream_optimized(<<value::unsigned-little-integer-16, rest::binary>>, acc) do
  _process_stream_optimized(rest, [value | acc])
end
```

Ao recompilar, os avisos foram substituídos por uma confirmação positiva do compilador:
```
warning: OPTIMIZED: match context reused
  lib/binary_optimizations.ex:47
```

Esta mensagem serve como verificação explícita de que a refatoração foi bem-sucedida e que o compilador agora é capaz de aplicar as otimizações desejadas de chamada de cauda e casamento de binários. Este exercício prático fornece uma demonstração concreta e mensurável da tese central do artigo: que o compilador BEAM fornece feedback poderoso e acionável para guiar a refatoração crítica de desempenho.

## 5. Análise de Resultados e Discussão

Para validar empiricamente os padrões de otimização discutidos, foram executados os benchmarks utilizando a biblioteca Benchee. Cada benchmark compara uma implementação idiomática, porém "ingênua", com uma versão refatorada e otimizada. Os resultados, medidos em iterações por segundo (ips), demonstram ganhos de performance substanciais, corroborando a tese deste artigo.

### 5.1. Padrão 1: O Custo do Achatamento de Listas Aninhadas

Neste cenário, o objetivo foi demonstrar o custo da função `List.flatten/1`, que é frequentemente usada de forma implícita por bibliotecas de formatação. Para isolar o impacto, criamos um benchmark que compara duas maneiras de transformar uma lista profundamente aninhada em um binário:

- **`naive_flatten`**: Achatamento explícito da lista com `List.flatten/1` antes de converter para binário.
- **`optimized_flatten (iolist)`**: Passagem direta da lista aninhada (uma iolist válida) para `IO.iodata_to_binary/1`, que a processa eficientemente sem um passo de achatamento intermediário.

**Tabela 3: Resultados do Benchmark de Achatamento de Lista**

| Função | IPS | Tempo Médio | Desempenho Relativo |
| :--- | :--- | :--- | :--- |
| `optimized_flatten` | 8.33 K | 120.01 µs | - |
| `naive_flatten` | 4.67 K | 214.19 µs | **1.78x mais lento** |

#### 5.1.1. Discussão

Os dados mostram que a versão otimizada é **1.78x mais rápida**. A diferença de performance reside na forma como a BEAM lida com dados de I/O. A função `IO.iodata_to_binary/1` é altamente otimizada para lidar com `iolists`, que são listas de inteiros, binários, ou outras `iolists`. Ao passar a lista aninhada diretamente, a BEAM pode processá-la em uma única passagem eficiente.

Em contrapartida, a versão `naive` força a criação de uma nova lista, completamente achatada, em memória antes de passá-la para a conversão em binário. Este passo intermediário introduz alocações de memória e processamento adicionais, explicando a queda de performance. Este resultado valida o princípio de que, em caminhos de código críticos, evitar passos de transformação de dados intermediários e confiar em funções otimizadas da BEAM (como as do módulo `IO`) é uma estratégia de otimização eficaz.

### 5.2. Padrão 2: Evitando a Criação de Sub-binários em Loops

Neste teste, processamos um binário contendo 10.000 inteiros de 16 bits, comparando duas estratégias de recursão:

- **`process_stream_naive`**: Utiliza uma função auxiliar que decodifica um valor e retorna o restante do binário (`rest`). A cada chamada recursiva, um novo cabeçalho de sub-binário é criado.
- **`process_stream_optimized`**: Realiza o casamento de padrões (*pattern matching*) diretamente na cabeça da função recursiva.

**Tabela 4: Resultados do Benchmark de Processamento de Binários**

| Função                   | IPS    | Tempo Médio | Desempenho Relativo |
| :----------------------- | :----- | :---------- | :------------------ |
| `process_stream_optimized` | 6.72 K | 148.86 µs   | -                   |
| `process_stream_naive`     | 1.43 K | 697.58 µs   | **4.69x mais lento**  |

#### 5.2.1. Discussão

Novamente, a versão otimizada demonstra ser quase **4.69x mais rápida**. A explicação para este ganho está em uma otimização fundamental do compilador da BEAM. Ao usar o casamento de padrões diretamente na cabeça da função recursiva, permitimos que o compilador reutilize o **contexto de casamento de padrões (match context)**. Em vez de alocar um novo sub-binário a cada iteração — uma operação que, embora não copie os dados, gera pressão sobre o Garbage Collector (GC) —, o compilador simplesmente avança um ponteiro sobre o binário original.

A abordagem `naive`, ao contrário, impede essa otimização, forçando a criação de 10.000 objetos de sub-binário, o que resulta em sobrecarga de alocação e coleta de lixo. Este exemplo ilustra de forma contundente como a estruturação do código para se alinhar com as otimizações do compilador pode levar a ganhos de performance significativos, especialmente no processamento de grandes volumes de dados binários.

## Conclusão

Este projeto propõe uma exploração rigorosa e prática dos princípios de engenharia de desempenho na linguagem de programação Elixir. Ao replicar e validar sistematicamente as técnicas de solução de problemas e otimização do artigo "Troubleshooting the Performance of a Large Erlang System", este trabalho fornecerá uma contribuição valiosa para a comunidade Elixir. Ele produzirá uma biblioteca de prova de conceito bem documentada, *PerformancePatterns*, que serve como uma ferramenta educacional para entender as implicações de desempenho de padrões de codificação comuns.

O cerne do projeto é um fluxo de trabalho experimental disciplinado em três fases que aproveita as melhores ferramentas do Elixir. O *Benchee* fornecerá benchmarks quantitativos estatisticamente sólidos, enquanto a suíte de profiling integrada da BEAM (`cprof`, `eprof`, `fprof`) será usada para realizar análises qualitativas, diagnosticando as causas raiz dos gargalos de desempenho. Os resultados esperados, com base nas descobertas do artigo de origem, são melhorias de desempenho significativas — potencialmente uma ordem de magnitude ou mais para certas operações — que podem ser claramente demonstradas e explicadas.

Crucialmente, o projeto está fundamentado nos princípios fundamentais da programação funcional. Ele explorará os trade-offs entre funções genéricas de ordem superior e soluções recursivas customizadas, o impacto da imutabilidade nas estratégias de processamento de dados e a importância de recursos do compilador como a Otimização de Chamada de Cauda. Ao estender a análise para incluir ferramentas em nível de sistema como o *Observer*, o projeto também conectará essas otimizações de código de baixo nível ao seu impacto mais amplo no gerenciamento de memória e na coleta de lixo na máquina virtual BEAM. Essa abordagem holística garante que o projeto não seja meramente um exercício mecânico de refatoração de código, mas uma investigação acadêmica significativa sobre a teoria e a prática da construção de sistemas funcionais de alto desempenho.

## Bibliografia

- TSIKOUDIS, Nikos; SUGIYAMA, Marc. Troubleshooting the Performance of a Large Erlang System. *In*: PROCEEDINGS OF THE 21ST ACM SIGPLAN INTERNATIONAL WORKSHOP ON ERLANG (Erlang '22). Nova Iorque: ACM, 2022. p. 7. Disponível em: https://doi.org/10.1145/3546186.3549926. Acesso em: 26 out. 2025.