USE CampFutebol;
GO

--PROCEDURE PARA ADICIONAR CADASTRAR TIMES
CREATE OR ALTER PROCEDURE USP_AdicionarTime @nome VARCHAR(30), @apelido VARCHAR(4), @anocri INT
AS 
BEGIN
    INSERT [Time]([nome], [apelido], [ano_cri]) VALUES (
        @nome, @apelido, @anocri
    )     
END;
GO

--PROCEDURE CADASTRANDO CAMPEONATO
CREATE OR ALTER PROCEDURE USP_Inicio_Camp @nome VARCHAR(20) 
AS
BEGIN
    INSERT [Campeonato]([nome]) VALUES(
        @nome
    )
END;
GO

--PROCEDURE RELIZAR JOGOS DO CAMPEONATO
CREATE OR ALTER PROCEDURE USP_Jogo_Camp @nome_Camp VARCHAR(20), @timeM VARCHAR(4), @timeV VARCHAR(4), @golM INT, @golV INT
AS
BEGIN
    DECLARE @numjogos INT
    SELECT @numjogos = c.num_jogos FROM Campeonato c WHERE c.nome = @nome_Camp


    if(@numjogos < 20 OR @numjogos IS NULL)
        INSERT [Jogo] ([nome_camp], [time_Mand], [time_Visit], [gol_Mand], [gol_Visi]) VALUES(
            @nome_Camp, @timeM, @timeV, @golM, @golV
        )
    ELSE
    BEGIN
        PRINT('Final de campeonato')    
    END    
END;
GO

--PROCEDURE PARA ADICIONAR TIMES AO CAMPEONATO
CREATE OR ALTER PROCEDURE USP_Inscrever_Campeonato @time VARCHAR(4), @camp VARCHAR(20)
AS
BEGIN
    DECLARE @numtime INT
    SELECT @numtime = c.num_equipes FROM Campeonato c WHERE c.nome = @camp
    IF(@numtime < 5 OR @numtime IS NULL)
        INSERT [InscreverCampeonato]([time], [campeonato]) VALUES (
            @time, @camp
        )
    ELSE
    BEGIN
        PRINT('Campeonato já atingiu limites de time.')
    END        
END;
GO



CREATE OR ALTER PROCEDURE USP_Final_Campeonato @nomecamp VARCHAR(20)
AS
BEGIN
    DECLARE @checkNumJogos INT
    SELECT @checkNumJogos = c.num_jogos FROM Campeonato c WHERE c.[nome] = @nomecamp
    IF(@checkNumJogos = 20)
    BEGIN
        SELECT c.[campeao] AS 'CAMPEAO' FROM Campeonato c WHERE c.[nome] = @nomecamp 
        SELECT t.[apelido] AS 'MAIS FEZ GOLS' FROM [time] t, [Jogo] j WHERE j.[gol_Mand] > j.[gol_Visi] AND j.[gol_Visi > gol_Mand] ,
        SELECT j.[time]    AS 'TOMOU MAIS GOLS',
        SELECT j.[time_Mand] AS 'JOGO COM MAIS GOLS'
        FROM Campeonato c JOIN InscreverCampeonato ic ON c.[nome] = ic.[campeonato]
        JOIN [time] t ON ic.[time] = t.[apelido] JOIN [Jogo] j ON ic.[time] = j.[time_Mand]  WHERE c.[nome] = @nome_Camp AND 
    END
    ELSE
    BEGIN
        PRINT('Campeonato nao encerrou.')
    END    
END;
GO