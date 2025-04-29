import java.sql.*;

public class MyClass {
    public static void main(String[] args) {

        String url = "jdbc:postgresql://192.168.178.51:1337/";
        String user = "paul";
        String password = "blah";

        try {
            // Load the PostgreSQL JDBC Driver
            Class.forName("org.postgresql.Driver");

            // Establish the connection
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                if (conn != null) {
                    System.out.println("Connected to the database!");

                    // Define the SQL query
                    // String sql = "SELECT * FROM xdoc WHERE docid = 221;";
                    String sql ="SELECT ASUM('nor', DOC(docid,0,38), 71) as dod,";
                    sql = sql + " HDV(DOC(docid,0,39)) as start_date,";
                    sql = sql + " HDV(DOC(docid,0,72)) as end_date,";
                    sql = sql + " DOC(docid,1,33) as status,";
                    sql = sql + " DOC2(docid,0,38) as nor,";
                    sql = sql + " ASUM('nor', DOC(docid,0,38), 6) as address,";
                    sql = sql + " UPRN(ASUM('nor', DOC(docid,0,38), 6)) as uprn";
                    sql = sql + " FROM xasum";
                    sql = sql + " WHERE type = 'eoc'";
                    sql = sql + " AND DOC(docid,1,33) = 'r'";
                    sql = sql + " AND (ISNULL(ASUM('nor', DOC(docid,0,38), 71))=1 OR DHV('1.1.1991') <= ASUM('nor', DOC(docid,0,38), 71))";
                    sql = sql + " AND DHV('1.1.1991') >= DOC(docid,0,39)";
                    sql = sql + " AND (DHV('1.1.1991') <= DOC(docid,0,72) OR ISNULL(DOC(docid,0,72))=1);"; 

                    // Create a statement object to execute the query
                    try (Statement stmt = conn.createStatement()) {
                        // Execute the query and retrieve the results
                        try (ResultSet rs = stmt.executeQuery(sql)) {
                            // Get the metadata of the result set
                            ResultSetMetaData rsMetaData = rs.getMetaData();
                            int columnCount = rsMetaData.getColumnCount();

                            // Print the column names
                            System.out.println("Query Results:");
                            for (int i = 1; i <= columnCount; i++) {
                                System.out.print(rsMetaData.getColumnName(i) + "\t");
                            }
                            System.out.println();

                            // Iterate through the result set and print each row
                            while (rs.next()) {
                                for (int i = 1; i <= columnCount; i++) {
                                    System.out.print(rs.getString(i) + "\t");
                                }
                                System.out.println();
                            }
                        }
                    }
                } else {
                    System.out.println("Failed to make connection!");
                }
            }
        } catch (SQLException e) {
            System.err.format("SQL State: %s\n%s", e.getSQLState(), e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}