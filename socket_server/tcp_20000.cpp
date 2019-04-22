#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <string.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <arpa/inet.h>
//#define MAXLINE 1024

int main(int argc,char **argv)
{
	int rec_socket,clent_addr;
	struct sockaddr_in serv_addr;
//	char buff[MAXLINE];
//        int n;

        rec_socket = socket(AF_INET,SOCK_STREAM,0);  // create server socket
    
        // bind socket,ip,port
	memset(&serv_addr,0,sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;  // only support ipv4
        serv_addr.sin_addr.s_addr = htonl(INADDR_ANY); // source ip: any ip
	serv_addr.sin_port = htons(20000);  // use 20000 port
	bind(rec_socket,(struct sockaddr *) &serv_addr,sizeof(serv_addr));

       // listening tcp conn
	listen(rec_socket,1024);
//        printf("wait client connection\n");
	for(;;)
	{
	  if((clent_addr = accept(rec_socket,(struct sockaddr*)NULL,NULL))==-1)
	  {
		  printf("accpet socket error: %s errno :%d\n",strerror(errno),errno);
		  continue;
	  }
//        n = recv(clent_addr,buff,MAXLINE,0);
//        buff[n] = '\0';
//        printf("recv msg from client:%s",buff);
	  close(clent_addr);
	}
	close(rec_socket);
}
