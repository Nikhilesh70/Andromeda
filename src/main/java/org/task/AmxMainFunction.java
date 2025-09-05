package org.task;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.*;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.json.JSONObject;

public class AmxMainFunction {
    // Use a single consistent file path for both reading and writing
    public static final String EXCEL_FILE_PATH = "C:\\Users\\Public\\NikhilWorkspace\\WebserviceLearning\\RegistrationDetails.xlsx";

    public static void main(String[] args) {
        String result = andremodauser();
        System.out.println(result);

        JSONObject jsonloginInput = new JSONObject();
        JSONObject jsonloginData = new JSONObject();
        jsonloginData.put("Username", "Latha123");
        jsonloginData.put("Password", "1234567");
        jsonloginInput.put("data", jsonloginData);

        String loginResult = validateLogin(jsonloginInput);
        System.out.println(jsonloginInput.toString(2));
        System.out.println(loginResult);
    }

    public static String andremodauser() {
        Map<String, String> hmdetails = new LinkedHashMap<>();
        hmdetails.put("Email", "sangatilatha@gmail.com");
        hmdetails.put("Username", "Latha123");
        hmdetails.put("Firstname", "Latha");
        hmdetails.put("Lastname", "Sangatipalle");
        hmdetails.put("Password", "1234567");
        hmdetails.put("ConfirmPassword", "1234567");
        hmdetails.put("Country", "India");

        boolean isDuplicate = false;

        try (FileInputStream fis = new FileInputStream(EXCEL_FILE_PATH);
             XSSFWorkbook workbook = new XSSFWorkbook(fis)) {

            XSSFSheet sheet = workbook.getSheet("Authentication");
            if (sheet == null) {
                System.out.println("Sheet 'Authentication' not found!");
                // Optionally, create sheet here
                return "{\"error\":\"Sheet not found\"}";
            }

            int lastRowIndex = sheet.getLastRowNum();

            // Check for duplicate email
            for (int i = 1; i <= lastRowIndex; i++) {
                XSSFRow row = sheet.getRow(i);
                if (row != null) {
                    XSSFCell emailCell = row.getCell(0);
                    if (emailCell != null && emailCell.getStringCellValue().equals(hmdetails.get("Email"))) {
                        isDuplicate = true;
                        break;
                    }
                }
            }

            if (!isDuplicate) {
                XSSFRow newRow = sheet.createRow(lastRowIndex + 1);
                newRow.createCell(0).setCellValue(hmdetails.get("Email"));
                newRow.createCell(1).setCellValue(hmdetails.get("Username"));
                newRow.createCell(2).setCellValue(hmdetails.get("Firstname"));
                newRow.createCell(3).setCellValue(hmdetails.get("Lastname"));
                newRow.createCell(4).setCellValue(hmdetails.get("Password"));
                newRow.createCell(5).setCellValue(hmdetails.get("ConfirmPassword"));
                newRow.createCell(6).setCellValue(hmdetails.get("Country"));
            } else {
                System.out.println("Duplicate email found, skipping addition.");
            }

            // Write changes to file
            try (FileOutputStream fos = new FileOutputStream(EXCEL_FILE_PATH)) {
                workbook.write(fos);
            }

        } catch (Exception e) {
            e.printStackTrace();
            return "{\"error\":\"" + e.getMessage() + "\"}";
        }

        Map<String, Object> finalMap = new LinkedHashMap<>();
        finalMap.put("Data", hmdetails);
        JSONObject jsonDetails = new JSONObject(finalMap);
        return jsonDetails.toString();
    }

    public static String validateLogin(JSONObject inputJson) {
        JSONObject mpresponse = new JSONObject();
        JSONObject data = inputJson.getJSONObject("data");
        String sUsername = data.getString("Username");
        String sPassword = data.getString("Password");

        try (FileInputStream fis = new FileInputStream(EXCEL_FILE_PATH);
             XSSFWorkbook workbook = new XSSFWorkbook(fis)) {

            XSSFSheet sheet = workbook.getSheet("Authentication");
            if (sheet == null) {
                return "{\"Message\":\"Sheet 'Authentication' not found\",\"Status\":\"Failed\"}";
            }

            int lastRowIndex = sheet.getLastRowNum();
            boolean isMatched = false;

            for (int i = 1; i <= lastRowIndex; i++) {
                XSSFRow row = sheet.getRow(i);
                if (row == null) continue;

                String Username = row.getCell(1).getStringCellValue();
                String Password = row.getCell(4).getStringCellValue();

                if (Username.equals(sUsername) && Password.equals(sPassword)) {
                    mpresponse.put("Message", "The user is matched");
                    mpresponse.put("Status", "Success");
                    isMatched = true;
                    break;
                }
            }

            if (!isMatched) {
                mpresponse.put("Message", "Invalid username or password");
                mpresponse.put("Status", "Failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            mpresponse.put("Message", "Error: " + e.getMessage());
            mpresponse.put("Status", "Failed");
        }

        return mpresponse.toString(2);
    }
}
