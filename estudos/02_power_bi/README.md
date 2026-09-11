# Estudos em Power BI — Caderno de Anotações

Caderno contínuo de anotações e estudos práticos baseado no curso de Power BI do instrutor João Paulo de Lira na Udemy.

---

## Objetivo
Registrar o aprendizado e a construção de projetos próprios ao longo do curso, cobrindo desde a ingestão e tratamento de dados no Power Query até a modelagem relacional, fórmulas DAX e criação de relatórios visuais.

---

## Estrutura de Pastas

* **[01_preparacao_dados/](./01_preparacao_dados/)**: Modelos e arquivos de teste de ETL, importação e tratamento de consultas. <!-- seção 1 a 5 do curso -->
* **[02_modelagem_dax/](./02_modelagem_dax/)**: Arquivos de relações, modelos relacionais e medidas/fórmulas DAX. <!-- seção 6 a 9 do curso -->
* **[03_visualizacao_dashboard/](./03_visualizacao_dashboard/)**: Relatórios finais autorais (`.pbix`/`.pbit`) e capturas de tela dos dashboards. <!-- seção 10 a 13 do curso -->

---

## Parte 1: Preparação e Tratamento de Dados
- **Anotações:**
  - Fluxo pra importar dados: Obter Dados -> escolher de onde vem os dados -> conectar -> carregar/editar dados (abre o power query pra edição dos dados). 
  - Na edição: olhar cabeçalhos, apagar colunas inúteis, editar formatação de colunas, limpar linhas em brancos e/ou linhas duplicadas e etc. 'Transformar dados pra reeditar tabelas'
  - Power Query: ferramenta ETL embutida no Power BI, criada para conectar, limpar, organizar e preparar dados de forma automatizada
  - Ao salvar um arquivo em .pbix, voce está salvando os dashboards realizados, as edições (etapas), sendo que as edições não são aplicadas no arquivo original (o arquivo que voce usou como base de dados). Nunca mova o arquivo base de dados sem mudar a referencia do power bi, se não ele perde de onde puxar os dados.
  - Formatação de colunas ('Transformar' vs. 'Adicionar coluna'): escolha entre alterar a própria coluna ou criar uma nova (recomendado para datas e estatísticas para não perder a informação original). Permite tratar textos (substituir valores, extrair ou dividir por delimitadores), números (operações matemáticas, arredondamentos e estatísticas — obs.: formatação de moeda não aparece no Power Query) e datas (opções para dia, semana, mês, ano e cálculo de idade).
  - Colunas condicionais: Criam-se colunas com bases em condições de outras colunas (Categorizar salários por exemplo), intuitivo e análogo a um if/else do python
  - Função 'Agrupar por', presente em 'Transformar' é funcionalmente igual ao GROUP BY do SQL, agrupa pela coluna selecionada
  - Função 'Mesclar Consultas' ou 'merge', presente em 'Página Inicial', é funcionalmente igual aos JOINs do SQL, combinando tabelas com base em colunas em comum
    - Interna ➔ `INNER JOIN` (apenas correspondências em ambas as tabelas)
    - Externa esquerda ➔ `LEFT JOIN` (tudo da 1ª tabela + correspondências da 2ª)
    - Externa direita ➔ `RIGHT JOIN` (tudo da 2ª tabela + correspondências da 1ª)
    - Externa completa ➔ `FULL JOIN` (todas as linhas de ambas as tabelas)
    - Anti esquerda ➔ `LEFT JOIN ... WHERE chave_direita IS NULL` (apenas registros exclusivos da 1ª)
    - Anti direita ➔ `RIGHT JOIN ... WHERE chave_esquerda IS NULL` (apenas registros exclusivos da 2ª)
  - Função 'Acrescentar consultas' ou 'append', serve pra juntar as linhas de duas tabelas que possuem as mesmas colunaa (nome), caso alguma das tabelas possuirem colunas que não estão em outras, essas colunas serão jogadas pro final da tabela.

## Parte 2: Modelagem e DAX
- **Anotações:**
  - Existe um 'padrão profissional' para criar uma tabela de datas usando essa linha: "= List.Dates(#date(1900,1,1), Number.From(DateTime.LocalNow())- Number.From(#date(1900,1,1)) ,#duration(1,0,0,0))". Ela cria uma tabela com todos os dias desde 01/01/1900. A partir daí, com formatação, voce pode adicionar colunas com as informações que julgar necessário.
  - Para criar relações, na modelagem entre tabelas do Power BI, usa-se o princípio de modelagem lógica de dados, com as mesmas ideias de Chaves Primárias, Estrangeira e Cardinalidade (Exemplo: Funcionários.DataDeNascimento(FK)  (*)----(1) Calendário.Datas(PK)).
  - Qual intuito de criar relações ? porque elas são importantes ?
    - As ferramentas visuais do BI utilizam a base de dados e as relações para funcionar, então elas são indispensáveis para criar dashboard mais dinâmicos e completos. As relações permitem que seleções de uma tabela consigam filtrar os dados das outras tabelas. Ela também evita criar uma tabela única enorme, isso aumenta performance
    - Tabelas Fato (f_): Registram os acontecimentos/eventos e métricas numéricas para cálculo (Ex: fVendas, fPedidos, fFolhaPagamento).
    - Tabelas Dimensão (d_): Registram o contexto e características para filtrar ou agrupar os dados nos visuais (Ex: dClientes, dFuncionários, dCargos, dCalendário).
    - Linhas e Colunas em matrizes: puxe de quem está saindo a seta da relação, o lado 1 da relação
    - É possível relacionar o mesmo par de tabelas uma ou mais vezes, sendo necessário delegar qual é a relação ativa.
    - Oque são fórmulas DAX ? fórmulas do power bi utilizadas sobre os dados das bases. As principais formas de se usar o DAX são:
      - Coluna calculada: Cria uma nova coluna física linha a linha dentro de uma tabela já existente. O cálculo é feito uma única vez durante a carga/atualização dos dados.
      - Medidas: Cálculos dinâmicos calculados "na hora". O valor muda dinamicamente dependendo dos filtros ou fatiadores que o usuário clicar no dashboard.
      - Tabelas calculadas: Uma tabela inteira nova gerada via código DAX, seja criada do zero ou derivada tabelas existentes.
    - No DAX:
      - podemos somar usando a sintaxe Tabela1[Coluna1] + Tabela1[Coluna2], usando +, -, *, /, ^ mesmo (espécie de coluna calculada)
      - operadores de comparação: >, <, <>, =, >=, <=
      - bool: true e false, apenas faz o DAX, Tabela[Coluna] {operador} {inteiro} -> true or false nas linhas
      - operadores especiais em dax
        - &: Concatenação, Nome & Sobrenome - Nome & " " & Sobrenome
        - &&: AND lógico -> 2 condições (1 e 1): DiasFolgas = horasextras > 8 && diasuteistrabalhados >= 200
        - ||: OR lógico -> 1 ou outro (0 e 1, 1 e 0, 1 e 1)
        - IN: operador de pertencimento, checar se um dado pertence a um conjunto
      - Principais formulas do DAX
        - FUNÇÃO IF (condição logica, resultado verdadeiro, resultado falso), podemos aninhá-los, ou 
        usar o SWITCH(TRUE())
        - Formulas de texto: LEFT(caracteres da esquerda), RIGHT(caracteres da direita), MID(da posição escolhida pra frente)
        - Formulas de data: YEAR(extrai o ano da data), podemos usar as características: .[Tempo], DATEDIFF, TODAY(), EOMONTH
        - Função Related:  Funciona como um JOIN do SQL. Estando na tabela Fato (lado Muitos '*'), ela busca e traz o valor de uma coluna da tabela Dimensão (lado Um '1') aproveitando a relação entre as chaves.
      - Em relação ao DAX pra criar medidas(métricas): medidas são como 'resumos' de uma coluna de uma informação, nas matrizes elas entram, geralmente, como valores.
      - Funções básicas de DAX pra medidas: SUM(soma valores de uma coluna), COUNT(conta numeros), COUNTA(conta numeros e texto), COUNTROWS(conta linhas), DISTINCTCOUNT(conta distintos), CALCULATE(calcula métrica mas com filtro desejado), ALL(apagador de filtros do DAX, usa se com o CALCULATE), FILTER(usado quando o filtro do CALCULATE é uma medida, pois o CALCULATE não permite métrica no filtro)
      - Funções Iterativas: SUMX(faz uma soma antes da foma de verdade, como se fosse um SUM mas pra mais de 1 coluna), AVERAGEX(analogo ao SUMX mas pra média), MAXX(pro máximo) -> 
       

---

<!-- ## Parte 3: Visualização, KPIs e Publicação

### Seção 10: Relatórios - O Resultado do BI
*Design visual, escolha correta de gráficos de acordo com os dados e princípios de UX/UI.*

- **Anotações:**
  - 

---

### Seção 11: Cartões, Mapas e Outras Ferramentas
*Uso de visuais de detalhe: cartões, novos cartões, mapas, filtros/segmentadores e interações entre visuais.*

- **Anotações:**
  - 

---

### Seção 12: Indicadores + KPI + Inteligência de Tempo
*Criação de indicadores de desempenho (KPIs) e funções de Time Intelligence (YTD, MTD, SAMEPERIODLASTYEAR).*

- **Anotações:**
  - 

---

### Seção 13: Publicar o Relatório
*Publicação no Power BI Service, compartilhamento de workspaces e agendamento de atualização.*

- **Anotações:**
  - 

--- 

## Dashboards Concluídos

Exiba aqui as capturas de tela e links dos relatórios que você mesmo construir:

Exemplo de como registrar seu projeto autoral:
### Nome do Meu Projeto
* **Descrição:** Breve resumo do objetivo do dashboard.
* **Arquivo:** [meu_dashboard.pbix](./03_visualizacao_dashboard/meu_dashboard.pbix)
* **Visualização:**
  ![Preview](./03_visualizacao_dashboard/preview.png)
--> 
