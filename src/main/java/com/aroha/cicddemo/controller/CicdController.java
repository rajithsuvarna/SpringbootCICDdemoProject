package com.aroha.cicddemo.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/cicd")
public class CicdController {

	@GetMapping
	public ResponseEntity<String> demoMethod(){
		return ResponseEntity.ok("Running Successfuly");
	}
	
}
