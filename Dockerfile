FROM httpd:2.2
    
COPY /web/  /usr/local/apache2/htdocs/

CMD ["httpd-foreground"]