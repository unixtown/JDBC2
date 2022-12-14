USE [master]
GO
/****** Object:  Database [GTR]    Script Date: 8/22/2022 9:01:15 AM ******/
CREATE DATABASE [GTR]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'GTR', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.YAMATOSQL\MSSQL\DATA\GTR.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'GTR_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.YAMATOSQL\MSSQL\DATA\GTR_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [GTR] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [GTR].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [GTR] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [GTR] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [GTR] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [GTR] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [GTR] SET ARITHABORT OFF 
GO
ALTER DATABASE [GTR] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [GTR] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [GTR] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [GTR] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [GTR] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [GTR] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [GTR] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [GTR] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [GTR] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [GTR] SET  DISABLE_BROKER 
GO
ALTER DATABASE [GTR] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [GTR] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [GTR] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [GTR] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [GTR] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [GTR] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [GTR] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [GTR] SET RECOVERY FULL 
GO
ALTER DATABASE [GTR] SET  MULTI_USER 
GO
ALTER DATABASE [GTR] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [GTR] SET DB_CHAINING OFF 
GO
ALTER DATABASE [GTR] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [GTR] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [GTR] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'GTR', N'ON'
GO
ALTER DATABASE [GTR] SET QUERY_STORE = OFF
GO
ALTER AUTHORIZATION ON DATABASE::[GTR] TO [YAMATO\unixt]
GO
USE [GTR]
GO
/****** Object:  User [gtr]    Script Date: 8/22/2022 9:01:15 AM ******/
CREATE USER [gtr] FOR LOGIN [gtr] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [cdc]    Script Date: 8/22/2022 9:01:15 AM ******/
CREATE USER [cdc] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[cdc]
GO
ALTER ROLE [db_datareader] ADD MEMBER [gtr]
GO
ALTER ROLE [db_owner] ADD MEMBER [cdc]
GO
GRANT CONNECT TO [cdc] AS [dbo]
GO
GRANT CONNECT TO [gtr] AS [dbo]
GO
GRANT SELECT TO [gtr] AS [dbo]
GO
GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO [public] AS [dbo]
GO
GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO [public] AS [dbo]
GO
/****** Object:  Schema [cdc]    Script Date: 8/22/2022 9:01:16 AM ******/
CREATE SCHEMA [cdc] AUTHORIZATION [cdc]
GO
/****** Object:  UserDefinedFunction [cdc].[fn_cdc_get_all_changes_dbo_Stock]    Script Date: 8/22/2022 9:01:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create function [cdc].[fn_cdc_get_all_changes_dbo_Stock]
	(	@from_lsn binary(10),
		@to_lsn binary(10),
		@row_filter_option nvarchar(30)
	)
	returns table
	return
	
	select NULL as __$start_lsn,
		NULL as __$seqval,
		NULL as __$operation,
		NULL as __$update_mask, NULL as [Qty], NULL as [Model], NULL as [Brand], NULL as [Id]
	where ( [sys].[fn_cdc_check_parameters]( N'dbo_Stock', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 0)

	union all
	
	select t.__$start_lsn as __$start_lsn,
		t.__$seqval as __$seqval,
		t.__$operation as __$operation,
		t.__$update_mask as __$update_mask, t.[Qty], t.[Model], t.[Brand], t.[Id]
	from [cdc].[dbo_Stock_CT] t with (nolock)    
	where (lower(rtrim(ltrim(@row_filter_option))) = 'all')
	    and ( [sys].[fn_cdc_check_parameters]( N'dbo_Stock', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 1)
		and (t.__$operation = 1 or t.__$operation = 2 or t.__$operation = 4)
		and (t.__$start_lsn <= @to_lsn)
		and (t.__$start_lsn >= @from_lsn)
		
	union all	
		
	select t.__$start_lsn as __$start_lsn,
		t.__$seqval as __$seqval,
		t.__$operation as __$operation,
		t.__$update_mask as __$update_mask, t.[Qty], t.[Model], t.[Brand], t.[Id]
	from [cdc].[dbo_Stock_CT] t with (nolock)     
	where (lower(rtrim(ltrim(@row_filter_option))) = 'all update old')
	    and ( [sys].[fn_cdc_check_parameters]( N'dbo_Stock', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 1)
		and (t.__$operation = 1 or t.__$operation = 2 or t.__$operation = 4 or
		     t.__$operation = 3 )
		and (t.__$start_lsn <= @to_lsn)
		and (t.__$start_lsn >= @from_lsn)
	
GO
ALTER AUTHORIZATION ON [cdc].[fn_cdc_get_all_changes_dbo_Stock] TO  SCHEMA OWNER 
GO
GRANT SELECT ON [cdc].[fn_cdc_get_all_changes_dbo_Stock] TO [public] AS [cdc]
GO
/****** Object:  UserDefinedFunction [cdc].[fn_cdc_get_net_changes_dbo_Stock]    Script Date: 8/22/2022 9:01:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create function [cdc].[fn_cdc_get_net_changes_dbo_Stock]
	(	@from_lsn binary(10),
		@to_lsn binary(10),
		@row_filter_option nvarchar(30)
	)
	returns table
	return

	select NULL as __$start_lsn,
		NULL as __$operation,
		NULL as __$update_mask, NULL as [Qty], NULL as [Model], NULL as [Brand], NULL as [Id]
	where ( [sys].[fn_cdc_check_parameters]( N'dbo_Stock', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 0)

	union all
	
	select __$start_lsn,
	    case __$count_89D4BFFD
	    when 1 then __$operation
	    else
			case __$min_op_89D4BFFD 
				when 2 then 2
				when 4 then
				case __$operation
					when 1 then 1
					else 4
					end
				else
				case __$operation
					when 2 then 4
					when 4 then 4
					else 1
					end
			end
		end as __$operation,
		null as __$update_mask , [Qty], [Model], [Brand], [Id]
	from
	(
		select t.__$start_lsn as __$start_lsn, __$operation,
		case __$count_89D4BFFD 
		when 1 then __$operation 
		else
		(	select top 1 c.__$operation
			from [cdc].[dbo_Stock_CT] c with (nolock)   
			where  ( (c.[Id] = t.[Id]) )  
			and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
			and (c.__$start_lsn <= @to_lsn)
			and (c.__$start_lsn >= @from_lsn)
			order by c.__$start_lsn, c.__$command_id, c.__$seqval) end __$min_op_89D4BFFD, __$count_89D4BFFD, t.[Qty], t.[Model], t.[Brand], t.[Id] 
		from [cdc].[dbo_Stock_CT] t with (nolock) inner join 
		(	select  r.[Id],
		    count(*) as __$count_89D4BFFD 
			from [cdc].[dbo_Stock_CT] r with (nolock)
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[Id]) m
		on t.__$seqval = ( select top 1 c.__$seqval from [cdc].[dbo_Stock_CT] c with (nolock) where  ( (c.[Id] = t.[Id]) )  and c.__$start_lsn <= @to_lsn and c.__$start_lsn >= @from_lsn order by c.__$start_lsn desc, c.__$command_id desc, c.__$seqval desc ) and
		    ( (t.[Id] = m.[Id]) ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_Stock', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and
				  (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_Stock_CT] c with (nolock) 
							where  ( (c.[Id] = t.[Id]) )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$start_lsn, c.__$command_id, c.__$seqval
						 ) 
	 			   )
	 			 )
	 			) 
			and t.__$operation = (
				select
					max(mo.__$operation)
				from
					[cdc].[dbo_Stock_CT] as mo with (nolock)
				where
					mo.__$seqval = t.__$seqval
					and 
					 ( (t.[Id] = mo.[Id]) ) 
				group by
					mo.__$seqval
			)	
	) Q
	
	union all
	
	select __$start_lsn,
	    case __$count_89D4BFFD
	    when 1 then __$operation
	    else
			case __$min_op_89D4BFFD 
				when 2 then 2
				when 4 then
				case __$operation
					when 1 then 1
					else 4
					end
				else
				case __$operation
					when 2 then 4
					when 4 then 4
					else 1
					end
			end
		end as __$operation,
		case __$count_89D4BFFD
		when 1 then
			case __$operation
			when 4 then __$update_mask
			else null
			end
		else	
			case __$min_op_89D4BFFD 
			when 2 then null
			else
				case __$operation
				when 1 then null
				else __$update_mask 
				end
			end	
		end as __$update_mask , [Qty], [Model], [Brand], [Id]
	from
	(
		select t.__$start_lsn as __$start_lsn, __$operation,
		case __$count_89D4BFFD 
		when 1 then __$operation 
		else
		(	select top 1 c.__$operation
			from [cdc].[dbo_Stock_CT] c with (nolock)
			where  ( (c.[Id] = t.[Id]) )  
			and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
			and (c.__$start_lsn <= @to_lsn)
			and (c.__$start_lsn >= @from_lsn)
			order by c.__$start_lsn, c.__$command_id, c.__$seqval) end __$min_op_89D4BFFD, __$count_89D4BFFD, 
		m.__$update_mask , t.[Qty], t.[Model], t.[Brand], t.[Id]
		from [cdc].[dbo_Stock_CT] t with (nolock) inner join 
		(	select  r.[Id],
		    count(*) as __$count_89D4BFFD, 
		    [sys].[ORMask](r.__$update_mask) as __$update_mask
			from [cdc].[dbo_Stock_CT] r with (nolock)
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[Id]) m
		on t.__$seqval = ( select top 1 c.__$seqval from [cdc].[dbo_Stock_CT] c with (nolock) where  ( (c.[Id] = t.[Id]) )  and c.__$start_lsn <= @to_lsn and c.__$start_lsn >= @from_lsn order by c.__$start_lsn desc, c.__$command_id desc, c.__$seqval desc ) and
		    ( (t.[Id] = m.[Id]) ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all with mask'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_Stock', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and
				  (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_Stock_CT] c with (nolock)
							where  ( (c.[Id] = t.[Id]) )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$start_lsn, c.__$command_id, c.__$seqval
						 ) 
	 			   )
	 			 )
	 			) 
			and t.__$operation = (
				select
					max(mo.__$operation)
				from
					[cdc].[dbo_Stock_CT] as mo with (nolock)
				where
					mo.__$seqval = t.__$seqval
					and 
					 ( (t.[Id] = mo.[Id]) ) 
				group by
					mo.__$seqval
			)	
	) Q
	
	union all
	
		select t.__$start_lsn as __$start_lsn,
		case t.__$operation
			when 1 then 1
			else 5
		end as __$operation,
		null as __$update_mask , t.[Qty], t.[Model], t.[Brand], t.[Id]
		from [cdc].[dbo_Stock_CT] t  with (nolock)
		where lower(rtrim(ltrim(@row_filter_option))) = N'all with merge'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_Stock', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and (t.__$seqval = ( select top 1 c.__$seqval from [cdc].[dbo_Stock_CT] c with (nolock) where  ( (c.[Id] = t.[Id]) )  and c.__$start_lsn <= @to_lsn and c.__$start_lsn >= @from_lsn order by c.__$start_lsn desc, c.__$command_id desc, c.__$seqval desc ))
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and 
				   (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_Stock_CT] c with (nolock)
							where  ( (c.[Id] = t.[Id]) )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$start_lsn, c.__$command_id, c.__$seqval
						 ) 
	 				)
	 			 )
	 			)
			and t.__$operation = (
				select
					max(mo.__$operation)
				from
					[cdc].[dbo_Stock_CT] as mo with (nolock)
				where
					mo.__$seqval = t.__$seqval
					and 
					 ( (t.[Id] = mo.[Id]) ) 
				group by
					mo.__$seqval
			)
	 
GO
ALTER AUTHORIZATION ON [cdc].[fn_cdc_get_net_changes_dbo_Stock] TO  SCHEMA OWNER 
GO
GRANT SELECT ON [cdc].[fn_cdc_get_net_changes_dbo_Stock] TO [public] AS [cdc]
GO
/****** Object:  Table [dbo].[Stock]    Script Date: 8/22/2022 9:01:16 AM ******/
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
GRANT SELECT ON [dbo].[Stock] TO [gtr] WITH GRANT OPTION  AS [dbo]
GO
/****** Object:  StoredProcedure [dbo].[GetGTR]    Script Date: 8/22/2022 9:01:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetGTR]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	

SELECT [Qty]
      ,[Model]
      ,[Brand]
      ,[Id]
  FROM [GTR].[dbo].[Stock]

END
GO
ALTER AUTHORIZATION ON [dbo].[GetGTR] TO  SCHEMA OWNER 
GO
USE [master]
GO
ALTER DATABASE [GTR] SET  READ_WRITE 
GO
