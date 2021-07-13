#!/bin/bash

OUTPUT="/dbs/scripts/backup_sqlsrv1"
STATUSERROR="STS_BKP_sqlsrv1_dia.log"
USERNAMEZABBIX="username"
IPZABBIX="ip_do_servidor_zabbix"
SENHAZABBIX="password"
DiaSem=`date +%a`

#Caputarando o Resultado da Execução do Backup
Result=`isql msdb usuario_bd senha_bd < $OUTPUT/consulta_dia_sqlsrv1.mysql | grep SQLRowCount | awk '{ print $3 }'`

#Capturando a Data da Execução do Backup
DATA=`isql msdb usuario_bd senha_bd < $OUTPUT/consulta_dia_sqlsrv1.mysql | grep "12:30" | cut -d "|" -f2 | cut -d " " -f2,3`

DATAERRO="`date +%Y-%m-%d` 12:30:00.000"

#Alterando a primeira letra do dia da semana de maiusculo para minusculo
if test $DiaSem = "Dom"; then DiaSem=`echo $DiaSem | tr D d`; fi;
	
#Armazenando o Resultado Sucesso ou Erro da Execução do Backup
if [ $Result = 1 ]; then
  echo "0 $DATA - [SQLSERVER1: SUCESSO]: SUCESSO NA EXECUÇÃO DO BACKUP DIARIO DO SERVIDOR: SQLSERVER1  !!!" > "$OUTPUT/log/dia/$STATUSERROR"
else
  if [ $DiaSem = "dom" ]; then
    echo "0 $DATA - [SQLSERVER1: NEUTRO]: BACKUP NÃO É EXECUTADO AOS DOMINGOS !!!" > "$OUTPUT/log/dia/$STATUSERROR"
  else    
    echo "1 $DATAERRO - [SQLSERVER1: ERROR]: ERRO NA EXECUÇÃO DO BACKUP DIARIO DO SERVIDOR: SQLSERVER1 !!!" > "$OUTPUT/log/dia/$STATUSERROR"
  fi    
fi

#Copiando o retorno da execução para o zabbix monitorar o status do backup
SSHPASS=`which sshpass > /dev/null; echo $?`
if [ ! $SSHPASS == 0 ]; then
	apt install -y sshpass
fi
sshpass -p $SENHAZABBIX scp "$OUTPUT/log/dia/$STATUSERROR" $USERNAMEZABBIX@$IPZABBIX:/dbs/scripts/zabbix/logs/backup_diario/
