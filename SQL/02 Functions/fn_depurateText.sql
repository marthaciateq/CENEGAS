CREATE FUNCTION [dbo].[fn_depurateText]
(
	@text VARCHAR(MAX)
)
RETURNS VARCHAR(max)
AS
BEGIN

	RETURN REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											LOWER(RTRIM(LTRIM(@text)))
										, ' ', '')
									, 'á', 'a') 
								, 'é', 'e')
							, 'í', 'i')
						, 'ó', 'o')
					, 'ú', 'u')
				, 'ü', 'u')
			, ',', '')
		, '"', '')

	
END
