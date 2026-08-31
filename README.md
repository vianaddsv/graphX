# Network Analysis with GraphX: MEDLINE Co-occurrence Pipeline

Este projeto implementa e reproduz a análise de redes de coocorrência de tópicos biomédicos baseada no Capítulo 7 do livro *Advanced Analytics with Spark* (Sanford Ryza, Uri Laserson, Sean Owen e Joshua Wills).

O pipeline processa registros brutos em XML da base MEDLINE/PubMed, modela as relações entre descritores médicos utilizando o Apache Spark GraphX, aplica filtragem estatística via teste Qui-Quadrado ($\chi^2$) e executa algoritmos distribuídos para analisar a topologia da rede (Componentes Conexas e distâncias de caminhos mais curtos via API Pregel).

---

## 🎯 Objetivo do Pipeline

* **Ingestão Distribuída de XML:** Utilização do `XMLInputFormat` da biblioteca Cloud9 para processar arquivos compactados da MEDLINE sem sobrecarregar a memória do Driver.
* **Extração de Tópicos:** Extração de descritores médicos principais (`MajorTopicYN == 'Y'`).
* **Construção do Grafo:** Geração de pares de coocorrência em cada artigo científico e mapeamento determinístico para identificadores de 64 bits via hashing MD5.
* **Poda Estatística:** Aplicação da métrica Qui-Quadrado ($\chi^2 > 19.5$) nas arestas para remover coocorrências casuais ou puramente aleatórias.
* **Análise Estrutural e Topológica:** 
  * Detecção de comunidades via Componentes Conexas.
  * Cálculo do Coeficiente de Agrupamento Médio.
  * Distribuição de distâncias de caminhos mais curtos via algoritmo iterativo Pregel (evidenciando a propriedade de rede *Small-World*).

---

## 🛠️ Pré-requisitos

* Docker e Docker Compose instalados na máquina.
* Utilitários padrão do Linux (`wget`, `gzip`).

---

## 📥 1. Download e Preparação dos Dados

O projeto consome as amostras oficiais da base MEDLINE (`medsamp2016a.xml` a `medsamp2016h.xml`).

Execute o arquivo `download_file.sh` na raiz do projeto:

Dê permissão de execução e execute o script:

```bash
chmod +x download_file.sh
./download_file.sh
```

---

## ⚙️ 2. Ajuste para Execução Local (Amostragem)

Para viabilizar o processamento iterativo do grafo no ambiente de desenvolvimento local e prevenir estouro de memória da JVM (`java.lang.OutOfMemoryError`), é aplicada uma limitação de amostragem no carregamento inicial dos dados dentro do `RunGraph.scala`:

```scala
val medlineRaw: Dataset[String] = loadMedline(spark, "/dados_medline").limit(10000)
```

> **Nota:** Essa amostragem de 10.000 registros valida a integridade de todas as etapas do grafo (cálculo de $\chi^2$, componentes conexas e iterações Pregel) consumindo menos recursos de hardware. Para execução em clusters distribuídos de produção (como Databricks), basta remover o `.limit(10000)` para processar o volume completo.

---

## 🐳 3. Configuração do Ambiente Docker

O ambiente utiliza a imagem oficial do Apache Spark (Scala 2.12 e Spark 3.5.1) com resolução dinâmica de dependências via Maven Central (`edu.umd:cloud9` e `scala-xml`).

Crie o arquivo `docker-compose.yml` na raiz:

```yaml
services:
  spark-env:
    image: bitnamilegacy/spark:3.5.1
    container_name: spark_medline_env
    volumes:
      - ./medline_data:/dados_medline
      - ./:/app/codigo
    stdin_open: true
    tty: true
    command: >
      spark-shell 
      --packages org.scala-lang.modules:scala-xml_2.12:2.1.0,edu.umd:cloud9:1.5.0 
      --driver-memory 4g
```

> **Nota de Ajuste de Memória:** Se optar por aumentar a amostra localmente, ajuste `--driver-memory` para `8g` e adicione `--conf spark.memory.fraction=0.8`.

---

## 🚀 4. Execução Passo a Passo

**Passo 1: Iniciar o contêiner interativo**
```bash
docker compose run --rm spark-env
```

**Passo 2: Carregar o script no Spark Shell**
Dentro do console interativo do Scala (`scala>`), compile e carregue o código-fonte:
```scala
scala> :load /app/codigo/RunGraph.scala
```

**Passo 3: Disparar a execução**
```scala
scala> RunGraph.main(Array())
```

---
## 📂 Estrutura do Projeto

```text
.
├── RunGraph.scala        # Algoritmo de processamento em GraphX
├── baixar_dados.sh       # Script de automação do download do dataset
├── docker-compose.yml    # Configuração do ambiente Spark
├── .gitignore            # Regras de exclusão do Git
├── README.md             # Documentação do projeto
└── medline_data/         # Diretório com os XMLs descompactados (gerado via script)
```
