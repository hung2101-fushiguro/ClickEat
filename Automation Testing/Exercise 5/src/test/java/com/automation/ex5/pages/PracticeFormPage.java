package com.automation.ex5.pages;

import java.nio.file.Path;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;

import com.automation.ex5.base.BasePage;

public class PracticeFormPage extends BasePage {

    private final By firstNameInput = By.id("firstName");
    private final By lastNameInput = By.id("lastName");
    private final By emailInput = By.id("userEmail");
    private final By genderMaleLabel = By.cssSelector("label[for='gender-radio-1']");
    private final By mobileInput = By.id("userNumber");
    private final By dateOfBirthInput = By.id("dateOfBirthInput");
    private final By subjectInput = By.id("subjectsInput");
    private final By hobbySportsLabel = By.cssSelector("label[for='hobbies-checkbox-1']");
    private final By uploadPictureInput = By.id("uploadPicture");
    private final By addressInput = By.id("currentAddress");
    private final By stateDropdown = By.id("state");
    private final By cityDropdown = By.id("city");
    private final By stateInput = By.id("react-select-3-input");
    private final By cityInput = By.id("react-select-4-input");
    private final By submitButton = By.id("submit");

    private final By resultModalTitle = By.id("example-modal-sizes-title-lg");
    private final By studentNameResult = By.xpath("//td[text()='Student Name']/following-sibling::td");
    private final By studentEmailResult = By.xpath("//td[text()='Student Email']/following-sibling::td");

    public PracticeFormPage(WebDriver driver) {
        super(driver);
    }

    public PracticeFormPage open(String url) {
        driver.get(url);
        ((JavascriptExecutor) driver).executeScript(
                "var fixed = document.getElementById('fixedban'); if (fixed) fixed.style.display='none';"
                + "var footer = document.querySelector('footer'); if (footer) footer.style.display='none';"
                + "document.querySelectorAll('iframe').forEach(function(frame){"
                + "  if(frame.id && frame.id.toLowerCase().includes('google_ads')) frame.style.display='none';"
                + "});"
        );
        return this;
    }

    public PracticeFormPage inputBasicInfo(String firstName, String lastName, String email, String mobile) {
        type(firstNameInput, firstName);
        type(lastNameInput, lastName);
        type(emailInput, email);
        click(genderMaleLabel);
        type(mobileInput, mobile);
        return this;
    }

    public PracticeFormPage setBirthDate(String dateText) {
        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].value=arguments[1];arguments[0].dispatchEvent(new Event('change',{bubbles:true}));",
                driver.findElement(dateOfBirthInput),
                dateText
        );
        return this;
    }

    public PracticeFormPage setSubject(String subject) {
        typeWithoutClear(subjectInput, subject);
        typeWithoutClear(subjectInput, "\n");
        return this;
    }

    public PracticeFormPage setHobbySports() {
        click(hobbySportsLabel);
        return this;
    }

    public PracticeFormPage uploadPicture(Path filePath) {
        driver.findElement(uploadPictureInput).sendKeys(filePath.toAbsolutePath().toString());
        return this;
    }

    public PracticeFormPage setAddress(String address) {
        type(addressInput, address);
        return this;
    }

    public PracticeFormPage setStateAndCity() {
        scrollIntoView(stateDropdown);
        click(stateDropdown);
        typeWithoutClear(stateInput, "NCR");
        typeWithoutClear(stateInput, "\n");
        click(cityDropdown);
        typeWithoutClear(cityInput, "Delhi");
        typeWithoutClear(cityInput, "\n");
        return this;
    }

    public PracticeFormPage submit() {
        scrollIntoView(submitButton);
        click(submitButton);
        return this;
    }

    public String getResultTitle() {
        return text(resultModalTitle);
    }

    public String getStudentNameResult() {
        return text(studentNameResult);
    }

    public String getStudentEmailResult() {
        return text(studentEmailResult);
    }
}
