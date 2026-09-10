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

<!-- ## Parte 2: Modelagem e DAX

### Seção 6: Relações
*Modelagem dimensional, esquemas relacionais (Star Schema / Snowflake), cardinalidade (1:N, N:1) e direção de filtro cruzado.*

- **Boas práticas:**
  - Tabelas Dimensão (entidades/contexto) vs. Tabelas Fato (eventos/números).
  - Evitar relacionamentos muitos-para-muitos (N:N) ou filtro bidirecional desnecessário.
- **Anotações:**
  - 

---

### Seção 7: Funções no Power BI - DAX
*Fundamentos da linguagem DAX (Data Analysis Expressions), colunas calculadas vs. medidas, contextos de linha e contexto de filtro.*

- **Anotações:**
  - 

---

### Seção 8: Principais Fórmulas DAX
*Dicionário de funções essenciais e exemplos de uso.*

| Função | Sintaxe / Exemplo | Finalidade |
| :--- | :--- | :--- |
| `CALCULATE` | `CALCULATE([Medida], Filtro)` | Modifica ou sobrescreve o contexto de filtro |
| `SUM` | `SUM(Tabela[Coluna])` | Soma simples de uma coluna numérica |
| `SUMX` | `SUMX(Tabela, Expressão)` | Função iteradora: avalia linha a linha e soma |
| `FILTER` | `FILTER(Tabela, Condição)` | Retorna uma tabela filtrada |
| `ALL` | `ALL(Tabela[Coluna])` | Remove filtros aplicados à coluna/tabela |

- **Anotações:**
  - 

---

### Seção 9: Medidas - Aplicação DAX
*Criação de medidas analíticas para negócio (ticket médio, margens, percentuais).*

- **Anotações:**
  - 

---

## Parte 3: Visualização, KPIs e Publicação

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
### 📌 Nome do Meu Projeto
* **Descrição:** Breve resumo do objetivo do dashboard.
* **Arquivo:** [meu_dashboard.pbix](./03_visualizacao_dashboard/meu_dashboard.pbix)
* **Visualização:**
  ![Preview](./03_visualizacao_dashboard/preview.png)
--> 
