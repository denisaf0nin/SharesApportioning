# PASTE INPUT

library(shiny)
library(openxlsx)
library(tidyverse)
library(rhandsontable)
library(data.table)
library(tibble)
library(stringr)

shinyServer(function(input, output, session) {
    
    # Reading xlsx:
    
    df<-as.data.frame(matrix(0, ncol = 20, nrow = 100))
    colnames(df)<-LETTERS[seq( from = 1, to = 20 )]
    rownames(df)<-seq(1:100)
    df[df==0]<-""
    
    
    # Reactive values:
    
    vals <- reactiveValues()
    
    observe({
        vals$df1 <- data.frame(df)
    })
    
    #  diff <- reactive({
    #    as.numeric(100-vals$df2[nrow(vals$df2), 6:ncol(vals$df2)])
    #  })
    
    
    
    # Building a table:
    
    output$table <- renderRHandsontable({
        if(!is.null(vals$df1))
            rhandsontable(vals$df1, selectCallback = TRUE)
        
    })
    
    observeEvent(input$table$changes$changes, {
        
        vals$df1 <- hot_to_r(input$table) 
        
    })
    
    # Crop
    
    observeEvent(input$crop, {
        vals$df1
        vals$df1<-vals$df1[rowSums(vals$df1==as.character(""), na.rm=TRUE) != ncol(vals$df1), colSums(vals$df1==as.character(""), na.rm=TRUE) != nrow(vals$df1)]
        colnames(vals$df1) <- as.character(vals$df1[1,])
        
        vals$df1 <- vals$df1%>%
            slice(-1)
        
        if('\r' %in% colnames(vals$df1))
        {
            vals$df1<-vals$df1 %>%
                select(-'\r') %>%
                as.data.frame()
        }
        
        vals$df1[5:ncol(vals$df1)]<-lapply(vals$df1[5:ncol(vals$df1)],FUN = as.numeric)
        colnames(vals$df1)
        
        vals$df1<- vals$df1%>%
            bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(., na.rm = TRUE) else "Total")))
        vals$df1 <- as.data.frame(append(vals$df1, list(Selected=TRUE), after = 4))
        vals$df1[nrow(vals$df1), "Selected"] <- FALSE
        
        vals$df2 <- as.data.frame(vals$df1)
        colnames(vals$df2)[6:ncol(vals$df2)]<-str_extract(colnames(vals$df2)[6:ncol(vals$df2)], "[[:digit:]]+")
        vals$df1 <- NULL
        
        shinyjs::hideElement(id="well1")
        shinyjs::showElement(id="well2")
        shinyjs::hideElement(id="crop")
        shinyjs::showElement(id="apportion")
        shinyjs::showElement(id="sel_all")
        shinyjs::showElement(id="desel_all")
    })
    
    output$table2 <- renderRHandsontable({
        if(!is.null(vals$df2))
            rhandsontable(vals$df2, selectCallback = TRUE) %>%
            hot_cols(columnSorting = FALSE) %>%
            hot_col(col = 6:ncol(vals$df2), renderer = "
              function (instance, td, row, col, prop, value, cellProperties) {
              Handsontable.renderers.NumericRenderer.apply(this, arguments);
              if (value > 100 | value < 0) {
              td.style.background = 'pink';
              }}") %>%
            hot_row(which(vals$df2$NBN == "Total"), readOnly = TRUE) %>%
            hot_table(highlightCol = TRUE, highlightRow = TRUE)
    })
    
    observeEvent(input$table2$changes$changes, {
        
        vals$df2 <- hot_to_r(input$table2) 
        vals$df2[which(vals$df2$NBN == "Total"),6:ncol(vals$df2)] <- vals$df2[-which(vals$df2$NBN == "Total"),6:ncol(vals$df2)]%>%
            summarise_all(., funs(if(is.numeric(.)) sum(., na.rm = TRUE)))
    })
    
    # Apportion
    
    observeEvent(input$sel_all, {
        vals$df2$Selected[1:nrow(vals$df2)-1]<-TRUE
    })
    
    observeEvent(input$desel_all, {
        vals$df2$Selected[1:nrow(vals$df2)-1]<-FALSE
    })
    
    observeEvent(input$apportion, {
        
        selected <- which(vals$df2$Selected == T)
        
        if(sum(vals$df2$Selected %in% TRUE)>=1) {
            sum_selected <- vals$df2 %>%
                filter(Selected == T) %>%
                select(6:ncol(vals$df2)) %>%
                summarise_all(funs(sum(., na.rm=T))) %>%
                as.numeric()
            
            m_selected <- vals$df2%>%
                filter(Selected == T) %>%
                select(6:ncol(vals$df2))%>%
                as.matrix()
            
            diff <- as.numeric(100-vals$df2[which(vals$df2$NBN == "Total"), 6:ncol(vals$df2)])
            
            addition <-  sweep(m_selected, 2, sum_selected, FUN = '/')%>%
                sweep(., 2, diff, FUN = '*')
            addition[is.nan(addition)] <- NA
            
            new <- data.frame(addition+m_selected)
            new[new>100]<-100
            new[new<0]<-0
            
            
            vals$df2[selected, 6:ncol(vals$df2)] <- new
            
            vals$df2[which(vals$df2$NBN == "Total"),6:ncol(vals$df2)] <- vals$df2[-which(vals$df2$NBN == "Total"),6:ncol(vals$df2)]%>%
                summarise_all(., funs(if(is.numeric(.)) sum(., na.rm = TRUE)))
        }
        
    })
    
})
