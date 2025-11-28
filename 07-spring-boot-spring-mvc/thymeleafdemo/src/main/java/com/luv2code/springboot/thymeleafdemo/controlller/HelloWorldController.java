package com.luv2code.springboot.thymeleafdemo.controlller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HelloWorldController {

    // new controller method to show initial HTML form
    @RequestMapping("/showForm")
    public String showForm() {

        return "helloworld-form";
    }

    // controller method to process HTML form data
    @RequestMapping("/processForm")
    public String processForm() {
        return "helloworld";
    }

    @RequestMapping("/processFormVersionTwo")
    public String letsShoutDude(HttpServletRequest request, Model model) {

        // read the request parameter from the HTML form
        String theName = request.getParameter("studentName");

        // convert the data to UPPERCASE
        theName = theName.toUpperCase();

        // create the message
        String result = "Yo! " + theName;

        // add message to the model
        model.addAttribute("message", result);

        return "helloworld";
    }

    @RequestMapping("/processFormVersionThree")
    public String processFormVersionThree(@RequestParam("studentName") String theName, Model model) {

        // convert the data to UPPERCASE
        theName = theName.toUpperCase();

        // create the message
        String result = "Hey my friend! " + theName;

        // add message to the model
        model.addAttribute("message", result);

        return "helloworld";
    }
}
