library(data.table)
# library(lfe)
library(lubridate)


### read data
stackdata2012 = fread("stackdata2012new.csv")
stackdata2011 = fread("stackdata2011new.csv")
stackdata = rbind(stackdata2011,stackdata2012)

## Dynamic Reputation
reputation2011 = fread("reputation2011.csv")
reputation2012 = fread("reputation2012.csv")
reputation = rbind(reputation2011,reputation2012)

## Competitor Answer Vote
answer_vote2011 = fread("competitor_vote2011.csv")
answer_vote2011[,postyear:=2011]
answer_vote2012 = fread("competitor_vote2012.csv")
answer_vote2012[,postyear:=2012]

answer_vote = rbind(answer_vote2011,answer_vote2012)

colnames(answer_vote)
head(answer_vote)

## pick up and rename variables
answer_vote = answer_vote[,list(user_id,postyear,postweek,comp_ans_upv = competitor_upvote,
                                comp_ans_dow = competitor_downvote)]

## Competitor Question Vote
question_vote2011 = fread("question_vote2011.csv")
question_vote2011[,postyear:=2011]
question_vote2012 = fread("question_vote2012.csv")
question_vote2012[,postyear:=2012]

question_vote = rbind(question_vote2011,question_vote2012)

colnames(question_vote)
head(question_vote)

## pick up and rename variables
question_vote = question_vote[,list(user_id,postyear,postweek,comp_que_upv = upvote,
                                comp_que_dow = downvote, comp_cum_que_upv = rolling_upvote,
                                comp_cum_que_dow = rolling_downvote)]

# ## replace NA with 0
# competitor_vote[is.na(competitor_vote)] <- 0


### Merge data
colnames(reputation)
colnames(stackdata)
data = merge(stackdata, reputation[,-"reputation"], by = c("user_id","postyear","postweek"), all.x = T)

## merge data with competitor answer upvote
colnames(answer_vote)
colnames(data)
data = merge(data,answer_vote, by = c("user_id","postyear","postweek"), all.x = T)

## merge data with competitor question upvote
colnames(question_vote)
colnames(data)
data = merge(data,question_vote, by = c("user_id","postyear","postweek"), all.x = T)


### Define date
data[,date :=  make_datetime(year = postyear) + weeks(postweek)]
table(data$date)

### Replace NA with 0
data[is.na(data)] <- 0

summary(data)

# zz1 <- felm(log1p(answer_give) ~ shift(log1p(AnsUpvRec))+shift(log1p(AnsDowRec))+shift(log1p(bronze)) + shift(log1p(silver))
#             + shift(log1p(gold))+ shift(log1p(ans_recive)) + shift(log1p(question_give)) + shift(log1p(question_upvote)) 
#             + shift(log1p(question_downvote))|user_id+date|0|user_id,data = stackdata)

colnames(data)

## Take log transformation
data[,`:=`(lans_giv = log1p(answer_give), lans_rec = log1p(ans_recive), lans_com = log1p(answer_com),
           lans_upv = log1p(AnsUpvRec), lans_dow = log1p(AnsDowRec),
           ledit = log1p(edit), lque_giv = log1p(question_give), lque_com = log1p(question_com),
           lque_upv = log1p(question_upvote),lque_dow = log1p(question_downvote),
           lgold = log1p(gold), lsilver = log1p(silver), lbronze = log1p(bronze),
           lrolling_reputation = log(21 + rolling_reputation), lcomp_ans_upv = log1p(comp_ans_upv),
           lcomp_ans_dow = log1p(comp_ans_dow), lcomp_que_upv = log1p(comp_que_upv),
           lcomp_que_dow = log1p(comp_que_dow), lcomp_cum_que_upv = log1p(comp_cum_que_upv), 
           lcomp_cum_que_dow = log1p(comp_cum_que_dow))]

## generate week index
data[,date_num := seq(1,.N, by = 1), by = user_id]


## write to STATA
library(foreign)
write.dta(data,"data.dta")


### Data is too large, select a random small sample with only 10,000 users
length(unique(data$user_id))
set.seed(666)
random_sample = sample(unique(data$user_id), 10000, replace = F)

###
data_random = data[user_id %in% random_sample]
write.dta(data_random,"data_random.dta")