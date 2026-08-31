# Network Analysis with GraphX: MEDLINE Co-occurrence Pipeline

Este projeto implementa e reproduz a análise de redes de coocorrência de tópicos biomédicos baseada no Capítulo 7 do livro *Advanced Analytics with Spark* (Sanford Ryza, Uri Laserson, Sean Owen e Joshua Wills). 

O pipeline processa registros brutos em XML da base MEDLINE/PubMed, modela as relações entre descritores médicos utilizando o Apache Spark GraphX, aplica filtragem estatística via teste Qui-Quadrado ($\chi^2$) e executa algoritmos distribuídos para analisar a topologia da rede (Componentes Conexas e distâncias de caminhos mais curtos via API Pregel).

---

## 🎯 Objetivo do Pipeline

1. **Ingestão Distribuída de XML:** Utilização do `XMLInputFormat` da biblioteca Cloud9 para processar arquivos compactados da MEDLINE sem sobrecarregar a memória do Driver.
2. **Extração de Tópicos:** Extração de descritores médicos principais (`MajorTopicYN == 'Y'`).
3. **Construção do Grafo:** Geração de pares de coocorrência em cada artigo científico e mapeamento determinístico para identificadores de 64 bits via hashing MD5.
4. **Poda Estatística:** Aplicação da métrica Qui-Quadrado ($\chi^2 > 19.5$) nas arestas para remover coocorrências casuais ou puramente aleatórias.
5. **Análise Estrutural e Topológica:** 
   - Detecção de comunidades via Componentes Conexas.
   - Cálculo do Coeficiente de Agrupamento Médio.
   - Distribuição de distâncias de caminhos mais curtos via algoritmo iterativo Pregel (evidenciando a propriedade de rede *Small-World*).

---

## 🛠️ Pré-requisitos

* **Docker** e **Docker Compose** instalados.
* Ferramentas de linha de comando: `wget` e `gzip`.

---

## 📥 1. Download e Preparação dos Dados

O projeto consome as amostras oficiais da base MEDLINE (`medsamp2016a.xml` a `medsamp2016h.xml`).

Rode o script `download_file.sh` na raiz do projeto
