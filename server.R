library(plyr)
shinyServer(function(input, output) {

  hs <- reactive({
    # Download the latest NCBI Homo sapiens gene information
    dload<-tempfile()
    download.file("http://ftp.ncbi.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz",dload)
    # Read the first 50 rows, determine column classes, and then read the entire data set using those classes
    hs<-read.table(dload,
                   header=TRUE,
                   sep="\t",
                   nrows=50,
                   quote="\"",
                   comment.char="#")
    classes<-sapply(hs,class)
    hs<-read.table(dload,
                   header=FALSE,
                   sep="\t",
                   quote="\"",
                   comment.char="#",
                   colClasses=classes,
                   fill=TRUE,
                   na.strings="-")
    # Select specific gene info (i.e. Entrez Gene ID, Gene Symbol, Chromosome, Description, and Gene Type)
    hs<-hs[,c(2:3,7,9,10)]
    colnames(hs)<-c("EntrezGeneID","Symbol","Chromosome","Description","GeneType")
    hs
    # This data can also be saved locally using: saveRDS(hs,file="geneInfo.R")
  })

  genes <- reactive({
    hs<-hs()
    # User-selected gene type
    type <- switch(input$type,
                   proteincoding="protein-coding",
                   tRNA="tRNA",
                   rRNA="rRNA",
                   snRNA="snRNA",
                   snoRNA="snoRNA",
                   ncRNA="ncRNA",
                   pseudo="pseudo",
                   other="other",
                   unknown="unknown")
    # If using a local file, read homo sapiens gene info
    #hs<-readRDS("data/geneInfo.R")
    # Drop complex chromosome levels
    hs<-hs[!(hs$Chromosome == "" | hs$Chromosome == "1|Un" | hs$Chromosome == "10|19|3" | hs$Chromosome == "MT" | hs$Chromosome == "Un" | hs$Chromosome == "X|Y"),]
    # Drop unused levels
    hs<-droplevels(hs)
    # Order chromosome factors
    levels(hs$Chromosome)<-c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y")
    # Subset by user-selected gene type
    genes<-hs[(hs$GeneType==type),]
    # Since we've selected a gene type, drop column 5 (GeneType) and NAs
    genes<-na.omit(genes[,c(1:4)])
    # Re-index rows
    rownames(genes)<-NULL
    genes
  })

  data <- reactive({
    genes<-genes()
    # Count genes by chromosome
    genes.sum<-ddply(genes,.(Chromosome),summarise,GeneCount=length(EntrezGeneID))
    # Drop incomplete cases
    genes.sum<-genes.sum[complete.cases(genes.sum),]
    # Re-index rows
    rownames(genes.sum)<-NULL
    genes.sum
  })

  output$totalnumbergenes <- renderPrint({
    nrow(genes())
  })

  output$plot <- renderPlot({
    genes.sum<-data()
    barplot(genes.sum$GeneCount,
            col="blue",
            names.arg=genes.sum$Chromosome,
            cex.names=0.7,
            ylim=c(0,max(genes.sum$GeneCount)*1.2),
            main="Gene Count per Chromosome",
            xlab="Chromosome",
            ylab="Number of Genes")
  })

  output$summary <- renderDataTable({
    genes.sum<-data()
    colnames(genes.sum)[2]<-"Gene Number"
    genes.sum
  },options=list(orderClasses=TRUE))

  output$table <- renderDataTable({
    genes<-genes()
  },options=list(orderClasses=TRUE))

  output$downloadData1 <- downloadHandler(
    filename = function() { paste(Sys.Date(),'gene-type-details.csv', sep='-') },
    content = function(file) { write.csv(genes(),file)
    })

  output$downloadData2 <- downloadHandler(
    filename = function() { paste(Sys.Date(),'gene-type-count-summary.csv', sep='-') },
    content = function(file) { write.csv(data(),file)
    })
})
