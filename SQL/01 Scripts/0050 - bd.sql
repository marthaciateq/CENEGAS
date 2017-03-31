USE [master]
GO

CREATE DATABASE CENEGAS ON PRIMARY ( 
	NAME = N'CENEGAS', 
	FILENAME = N'C:\data\CENEGAS.mdf' , 
	SIZE = 3072KB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 1024KB 
),
FILEGROUP BINARY_DATA
	(NAME = N'CENEGAS_binary_data',
    FILENAME = N'C:\data\CENEGAS_binary_data.mdf',
    SIZE = 8GB,
    MAXSIZE = 128GB,
    FILEGROWTH = 4GB)
LOG ON (
	NAME = N'CENEGAS_log', 
	FILENAME = N'C:\data\CENEGAS_log.ldf' , 
	SIZE = 1024KB , 
	MAXSIZE = 2048GB , 
	FILEGROWTH = 10%
)
GO

USE CENEGAS
GO

EXECUTE sp_changedbowner @loginame = N'cenegasAdmin', @map = false
GO

CREATE USER cenegasDefault FROM LOGIN cenegasDefault 