package com.automation.ex5.tests;

import com.automation.ex5.base.BaseTest;
import com.automation.ex5.pages.PracticeFormPage;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class PracticeFormRegisterTest extends BaseTest {

    @Test
    void shouldSubmitPracticeFormSuccessfully() throws IOException {
        Path tempImage = Files.createTempFile("demoqa-register", ".png");

        PracticeFormPage practiceFormPage = new PracticeFormPage(driver)
                .open(getBaseUrl())
                .inputBasicInfo("An", "Nguyen", "an.nguyen@example.com", "0987654321")
                .setBirthDate("15 Mar 1999")
                .setSubject("Maths")
                .setHobbySports()
                .uploadPicture(tempImage)
                .setAddress("123 Le Loi, Ho Chi Minh")
                .setStateAndCity()
                .submit();

        Assertions.assertEquals("Thanks for submitting the form", practiceFormPage.getResultTitle());
        Assertions.assertEquals("An Nguyen", practiceFormPage.getStudentNameResult());
        Assertions.assertEquals("an.nguyen@example.com", practiceFormPage.getStudentEmailResult());
    }
}
