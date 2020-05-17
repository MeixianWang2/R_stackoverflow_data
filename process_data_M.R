library(data.table)
# library(lfe)
library(lubridate)


stackdata2012 = fread("answer_given_2012.csv")
stackdata2012[,postyear:=2012]
colnames(stackdata2012)
head(stackdata2012)
stackdata2011 = fread("answer_given_2011.csv")
stackdata2011[,postyear:=2011]
colnames(stackdata2011)
head(stackdata2011)
rolling_answer_given= rbind(stackdata2011,stackdata2012,use.names = FALSE)
colnames(rolling_answer_given)
head(rolling_answer_given)
library(foreign)
write.csv(rolling_answer_given,"rolling_answer_given.csv")


stackdata2012 = fread("bounty2012.csv")
stackdata2012[,postyear:=2012]
head(stackdata2012)
stackdata2011 = fread("bounty2011.csv")
stackdata2011[,postyear:=2011]
colnames(stackdata2011)
head(stackdata2011)

bounty_data= rbind(stackdata2011,stackdata2012)
colnames(bounty_data)
head(bounty_data)
library(foreign)
write.csv(bounty_data,"bounty_data.csv")
