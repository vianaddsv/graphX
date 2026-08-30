#!/bin/bash

# Cria a pasta de dados se não existir
mkdir -p medline_data

echo "Baixando a sequência de arquivos MEDLINE..."
wget ftp://ftp.nlm.nih.gov:21/nlmdata/sample/medline/medsamp2016{a..h}.xml.gz -P medline_data/

echo "Descompactando os arquivos XML..."
gunzip -f medline_data/*.gz

echo "Tudo pronto! Os arquivos XML estão extraídos na pasta medline_data/"
