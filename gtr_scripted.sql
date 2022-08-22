USE [GTR]
GO

/****** Object:  Table [dbo].[Stock]    Script Date: 8/22/2022 8:51:58 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stock]') AND type in (N'U'))
DROP TABLE [dbo].[Stock]
GO

/****** Object:  Table [dbo].[Stock]    Script Date: 8/22/2022 8:51:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Stock](
	[Qty] [int] NULL,
	[Model] [varchar](50) NOT NULL,
	[Brand] [varchar](50) NOT NULL,
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Stock] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER AUTHORIZATION ON [dbo].[Stock] TO  SCHEMA OWNER 
GO

GRANT SELECT ON [dbo].[Stock] TO [gtr] AS [dbo]
GO

