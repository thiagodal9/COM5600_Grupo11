CREATE DATABASE ParquesNacionales;
GO

USE ParquesNacionales;
GO

CREATE SCHEMA PnTablas;
GO

CREATE TABLE PnTablas.TipoParque
(
	IDTipoParque INT IDENTITY(1, 1) PRIMARY KEY,
	DescripcionParque varchar(30)
);

CREATE TABLE PnTablas.Provincia
(
	IDProv INT IDENTITY(1, 1) PRIMARY KEY,
	NombreProv varchar(15)
);

CREATE TABLE PnTablas.Parque
(
	IDParque INT IDENTITY(1, 1) PRIMARY KEY,
	NombreParque varchar(30),
	Ubicacion INT,
	Superficie INT,
	Tipo INT,
	FOREIGN KEY(Ubicacion) REFERENCES PnTablas.Provincia(IDProv),
	FOREIGN KEY(Tipo) REFERENCES PnTablas.TipoParque(IDTipoParque)
);

CREATE TABLE PnTablas.Dia
(
	IDDia INT IDENTITY(1, 1) PRIMARY KEY,
	NombreDia varchar(10)
);

CREATE TABLE PnTablas.HorarioParque
(
	IDHorarioP INT IDENTITY(1, 1) PRIMARY KEY,
	HoraApertura TIME,
	HoraCierre TIME,
	Temporada varchar(10)
);

CREATE TABLE PnTablas.Abre
(
	Parque INT,
	Dia INT,
	Horario INT,
	FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
	FOREIGN KEY(Dia) REFERENCES PnTablas.Dia(IDDia),
	FOREIGN KEY(Horario) REFERENCES PnTablas.HorarioParque(IDHorarioP)
);

CREATE TABLE PnTablas.TelefonoParque
(
	NumeroParque varchar(12),
	Parque INT,
	FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
	PRIMARY KEY(NumeroParque, Parque)
);

CREATE TABLE PnTablas.TipoActividad
(
	IDTipoAct INT IDENTITY (1, 1) PRIMARY KEY,
	DescripcionAct varchar(30),
	CostoAct DECIMAL(7, 2)
);

CREATE TABLE PnTablas.ActividadParque
(
	IDActividadP INT IDENTITY(1, 1) PRIMARY KEY,
	NombreActividad varchar(30),
	Duracion INT,
	CupoMax INT,
	Parque INT,
	Tipo INT,
	Guia INT,
	FOREIGN KEY (Parque) REFERENCES PnTablas.Parque(IDParque),
	FOREIGN KEY (Tipo) REFERENCES PnTablas.TipoActividad(IDTipoAct),
	FOREIGN KEY (Guia) REFERENCES PnTablas.Guia(IDGuia)
);