package app;
import java.sql.*;

public class APPN {
	
	private static final String JDBC_URL = "jdbc:sqlserver://localhost:1433;database=ParquesNacionales;encrypt=false;user=APP;password=ABCD";
	private Connection conexion;
	private Statement operacion;
	private ResultSet result;
	private SQLWarning warning;
	private boolean estado;
	
	public APPN() 
	{
		estado = false;
	}

	public void crearConexion()
	{
		try 
		{
			conexion = DriverManager.getConnection(JDBC_URL);
			operacion = conexion.createStatement();
			
			System.out.println("--Conexion exitosa.--\n");
			estado = true;
		} 
		catch (SQLException e) 
		{e.printStackTrace();}
	}
	
	public boolean isActivo() {
		return estado;
	}

	public void setEstado(boolean estado) {
		this.estado = estado;
	}

	public void verParques()
	{
		String lineaOperacion = "EXECUTE PnSP.verParques";
		
		try 
		{
			result = operacion.executeQuery(lineaOperacion);
			
			if(result.isBeforeFirst())
			{
				System.out.println("--RESULTADO:\n");
				while( result.next() )
				{
					System.out.println
					(
					"ID del Parque: " + result.getString("IDParque") 
					+ ", " + 
					"Nombre del Parque: " + result.getString("NombreParque")
					+ ", " +
					"Ubicacion: " + result.getString("Ubicacion")
					+ ", " +
					"Superficie: " + result.getString("Superficie")
					+ ", " +
					"Tipo de Parque: " + result.getString("Tipo")
					);
				}
			}
			else
				System.out.println("--No hay parques para mostrar.--");
		} 
		catch (SQLException e) 
		{e.printStackTrace();}
		
		System.out.println("\n");
	}
	
	public void verTiposParque()
	{
		String lineaOperacion = "EXECUTE PnSP.verTipoParque";
		
		try 
		{
			result = operacion.executeQuery(lineaOperacion);
			
			if(result.isBeforeFirst())
			{
				System.out.println("--RESULTADO:\n");
				while( result.next() )
				{
					System.out.println
					("ID del Tipo: " + result.getString("IDTipoParque") 
					+ ", " 
					+ "Descripcion: " + result.getString("DescripcionParque"));
				}
			}
			else
				System.out.println("--No hay tipos para mostrar.--");
		} 
		catch (SQLException e) 
		{e.printStackTrace();}
		
		System.out.println("\n");
	}
	
	public void verProvincia()
	{
		String lineaOperacion = "EXECUTE PnSP.verProvincia";
		
		try 
		{
			result = operacion.executeQuery(lineaOperacion);
			
			if(result.isBeforeFirst())
			{
				System.out.println("--RESULTADO:\n");
				while( result.next() )
				{
					System.out.println
					("ID de Provincia: " + result.getString("IDProv") 
					+ ", " 
					+ "Nombre de Provincia: " + result.getString("NombreProv"));
				}
			}
			else
				System.out.println("--No hay provincias para mostrar.--");
		} 
		catch (SQLException e) 
		{e.printStackTrace();}
		
		System.out.println("\n");
	}
	
	public void altaParque(String nombre, int ubicacion, int superficie, int tipo)
	{
		String lineaOperacion = "EXECUTE PnSPabm.altaParque @nombre = '" + nombre + "'"
														+ ", @ubicacion = " + String.valueOf(ubicacion) 
														+ ", @superficie = " + String.valueOf(superficie) 
														+ ", @tipo = " + String.valueOf(tipo);
		
		try 
		{
			operacion = conexion.createStatement();
			
			operacion.execute(lineaOperacion);
			warning = operacion.getWarnings();
			
			if(warning != null)
			{
				while (warning != null) 
				{
				    System.out.println(warning.getMessage());
				    warning = warning.getNextWarning();
				}
			}
			else
				System.out.println("--Operacion exitosa.--\n");
		} 
		catch (SQLException e) 
		{e.printStackTrace();}
	}
	
	public void modificarNombreParque(int parque, String nombreNEW)
	{
		String lineaOperacion = "EXECUTE PnSPabm.modificarNombreParque  @parque = " + String.valueOf(parque) 
																		+ ", @nombreNEW = '" + nombreNEW + "'";
		try 
		{
			operacion = conexion.createStatement();
			
			operacion.execute(lineaOperacion);
			warning = operacion.getWarnings();
			
			if(warning != null)
			{
				while (warning != null) 
				{
				    System.out.println(warning.getMessage());
				    warning = warning.getNextWarning();
				}
			}
			else
				System.out.println("--Operacion exitosa.--\n");
		} 
		catch (SQLException e) 
		{e.printStackTrace();}
	}
	
	public void modificacionSuperficieParque(int parque, int superficieNew)
	{
		String lineaOperacion = "EXECUTE PnSPabm.modificarSuperficieParque  @parque = " + String.valueOf(parque) 
																		+ ", @superficieNEW = " + String.valueOf(superficieNew);
		try 
		{
			operacion = conexion.createStatement();
			
			operacion.execute(lineaOperacion);
			warning = operacion.getWarnings();
			
			if(warning != null)
			{
				while (warning != null) 
				{
				    System.out.println(warning.getMessage());
				    warning = warning.getNextWarning();
				}
			}
			else
				System.out.println("--Operacion exitosa.--\n");
		} 
		catch (SQLException e) 
		{e.printStackTrace();}
	}
	
	public void bajaParque(int parque)
	{
		String lineaOperacion = "EXECUTE PnSPabm.bajaParque @parque = " + String.valueOf(parque);
		try 
		{
			operacion = conexion.createStatement();
			
			operacion.execute(lineaOperacion);
			warning = operacion.getWarnings();
			
			if(warning != null)
			{
				while (warning != null) 
				{
				    System.out.println(warning.getMessage());
				    warning = warning.getNextWarning();
				}
			}
			else
				System.out.println("--Operacion exitosa.--\n");
		} 
		catch (SQLException e) 
		{e.printStackTrace();}
	}
	
	public void cerrarConexion()
	{
		if (result != null) 
		{
	        try 
	        {result.close();} 
	        catch (SQLException e) 
			{e.printStackTrace();}
	    }
		
	    if (operacion != null) 
	    {
	        try {operacion.close();} 
	        catch (SQLException e) 
			{e.printStackTrace();}
	    }
	    
	    if (conexion != null) 
	    {
	        try {conexion.close();} 
	        catch (SQLException e) 
			{e.printStackTrace();}
	    }
	}
}