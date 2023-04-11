CREATE DATABASE CAMPEONATOFUT
GO
USE CAMPEONATOFUT
GO

CREATE TABLE Time (
    [apelido] VARCHAR(4) NOT NULL,
    [nome] VARCHAR(30) NOT NULL,
    [ano_cri] INT NOT NULL

    CONSTRAINT PK_Time PRIMARY KEY ([apelido])
)
GO

CREATE TABLE Campeonato (
    [nome] VARCHAR(20) NOT NULL,
    [ano] INT NOT NULL,
    [num_equipes] INT NULL,
    [campeao] VARCHAR(4) NULL,
    [num_jogos] INT NULL

    CONSTRAINT PK_Campeonato PRIMARY KEY ([nome],[ano])
)
GO

CREATE TABLE InscreverCampeonato (
    [time] VARCHAR(4) NOT NULL,
    [campeonato] VARCHAR(20) NOT NULL,
    [ano_camp] INT NOT NULL,
    [pontos] INT NULL,
    [saldo_gols] INT NULL,
    [maiorgol] INT NULL

    CONSTRAINT PK_InscrCamp PRIMARY KEY ([time],[campeonato],[ano_camp])
    CONSTRAINT FK_InscrCamp_Time FOREIGN KEY ([time]) REFERENCES [Time]([apelido]),
    CONSTRAINT FK_InscrCamp_Campeonato FOREIGN KEY ([campeonato],[ano_camp]) REFERENCES [Campeonato]([nome],[ano])
);
GO

CREATE TABLE Jogo (
    [time_Mand] VARCHAR(4) NOT NULL,
    [time_Visit] VARCHAR(4) NOT NULL,
    [nome_camp] VARCHAR(20) NOT NULL,
    [ano_camp] INT NOT NULL,
    [gol_Mand] INT NOT NULL,
    [gol_Visi] INT NOT NULL,

    CONSTRAINT PK_Jogo PRIMARY KEY ([time_Mand],[time_Visit],[nome_camp],[ano_camp]),
    CONSTRAINT FK_Jogo_TimeM FOREIGN KEY ([time_Mand],[nome_camp],[ano_camp]) REFERENCES [InscreverCampeonato]([time],[campeonato],[ano_camp]),
    CONSTRAINT FK_Jogo_TimeV FOREIGN KEY ([time_Visit], [nome_camp],[ano_camp]) REFERENCES [InscreverCampeonato]([time],[campeonato],[ano_camp]),
    CONSTRAINT CHK_TimeM CHECK (time_Mand <> time_Visit ) 
)
GO

--DESCOMENTE APOS EXECUTAR SCRIPTS DE PROCEDURES E TRIGGERS
/*
--ORDEM ADICIONAR CAMPEONATO - [nome campeonato],[ano campeonato]
EXEC.USP_Inicio_Camp 'Brasileiro', 2022

--ORDEM ADICIONAR TIME - [NOME],[SIGLA/APELIDO],[ANO CRIACAO]
EXEC.USP_Adicionar_Time 'Corinthians', 'COR', 1985

--ORDEM INSCRICAO CAMPEONATO - [SIGLA/APELIDO TIME], [CAMPEONATO], [ANO CAMPEONATO]
EXEC.USP_Inscrever_Campeonato 'SPF', 'Brasileiro', 2022

--ORDEM INSERIR RESULTADO JOGO - [CAMPEONATO],[ANO],[SIGLA/APELIDO CASA],[SIGLA/APELIDO VISITANTE],[GOL CASA],[GOL VISITANTE]
EXEC.USP_Jogo_Camp 'Brasileiro', 2022,'SPF', 'SAN', 0, 0


--EXIBICAO
SELECT * FROM [Time]                          --TIMES REGISTRADOS
SELECT * FROM [Campeonato]                    --INFORMACOES CAMPEONATO
SELECT * FROM [Jogo]                          --JOGOS QUE JA ACONTECERAM
EXEC.USP_Tabela_Campeonato 'Brasileiro', 2022 --TABELA CLASSIFICACAO CAMPEONATO
EXEC.USP_Final_Campeonato 'Brasileiro', 2022  --ESTATISTICAS (SOMENTE APOS O TERMINO DO CAMPEONATO)
*/