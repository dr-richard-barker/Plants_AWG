#Build a package for the analysis pipeline used in RACARA
#Working title: Gene Lab Analysis Pipeline (GLAP)
#This pipeline could be used for the next step of GeneLab RNAseq bioinformatics Standard Data processing pipeline
#Starts with accessing metadata for each mission to review what kind of study resarchers want to use and proceed to analyze
#1.Metadata review

##*Add Search API? Apply Visualization GeneLab API?* 


#GeneLab Metadata RestAPI test
#Purpose: display the important metadata of the mission and give the option to import processed data such as Normalized counts or DEG data

library("httr")
GeneLab_server<-"https://genelab-data.ndc.nasa.gov"
DataQuery_base<-"https://genelab-data.ndc.nasa.gov/genelab/data/glds/files/"
Metadata_base<-"https://genelab-data.ndc.nasa.gov/genelab/data/glds/meta/"

mission_num<-"120"  #user input #send error code if no mission_num available and give directions? Find mission with Genelab processed RNAseq data

DataQuery_120api<-paste(DataQuery_base, mission_num, sep="")
Metadata_120api<-paste(Metadata_base, mission_num, sep="")

DataQuery_120 <- GET(url = DataQuery_120api)
Metadata_120 <- GET(url = Metadata_120api)

status_code(DataQuery_120) #check#if not 200 send error message
#str(content(DataQuery_120))

status_code(Metadata_120) #check#if not 200 send error message
#str(content(Metadata_120))

DQ_120text <- content(DataQuery_120, as = "text", encoding = "UTF-8") 
MD_120text <- content(Metadata_120, as = "text", encoding = "UTF-8")

library(jsonlite)

DQjson120 <- fromJSON(DQ_120text,flatten = TRUE)
MDjson120 <- fromJSON(MD_120text,flatten = TRUE)

DQ120 <- as.data.frame(DQjson120)
View(DQ120) 

library(tidyverse)

Available_csv<-DQ120 %>% 
  select(contains("file_name")) %>%
  filter_all(all_vars((grepl('csv',.)))) ## get rownum from this #if no csv file available send error message
Download_key<-DQ120 %>%
  select(contains("remote_url")) %>%
  filter_all(all_vars((grepl('csv',.)))) ##same rownum for the file then paste with GLserver

test<-read.csv(paste(GeneLab_server, Download_key[2,], sep = ""))

#Useful dfs #On the console only display the essential metadata and provide options to see other metadata
Mission_Title<-as.data.frame(MDjson120$study$`GLDS-120`$isa2json$studies)["title"]
Mission_Description<-as.data.frame(MDjson120$study$`GLDS-120`$isa2json$studies)["description"]
Dates<-as.data.frame(MDjson120$study$`GLDS-120`$isa2json$studies)[c("submissionDate","publicReleaseDate")]
Authors<-as.data.frame(MDjson120$study$`GLDS-120`$isa2json$studies$people)[c("lastName", "firstName", "midInitials", "email", "affiliation")]
Protocols<-as.data.frame(MDjson120$study$`GLDS-120`$isa2json$studies$protocols)[c("name","description")]
Assay_Description<-as.data.frame(MDjson120$study$`GLDS-120`$isa2json$additionalInformation$description$assays)
Basic_Info<-as.data.frame(MDjson120$study$`GLDS-120`$isa2json$studies$comments)
Materials<-as.data.frame(MDjson120$study$`GLDS-120`$isa2json$studies$materials.sources)["name"]
StudyDesign_Factor<-as.data.frame(MDjson120$study$`GLDS-120`$isa2json$studies$factors)["factorName"] #Key for dividing the dataset

#Bit raw/big but useful data 
Sample_Data<-MDjson120$study$`GLDS-120`$isa2json$additionalInformation$samples$`s_GSE94983-txt`$table
Assay_Data<-MDjson120$study$`GLDS-120`$isa2json$additionalInformation$assays$`a_gse94983_transcription_profiling_RNA_Sequencing_(RNA-Seq)-txt`$table
