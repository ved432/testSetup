/// <reference types="Cypress" />

import apis from "../../../kube-apis/apis";
const TOKEN = Cypress.env("KUBE_API_TOKEN");

describe("Examples for Cluster Operations", () => {
  it("Test to get workflows in litmus namespace", () => {
    cy.request({
      url: apis.getWorkflows("litmus"),
      method: "GET",
      headers: {
        Authorization: `Bearer ${TOKEN}`,
      },
    }).should((response) => {
      const workflows = response.body.items;
      workflows.map((workflow) => {
        cy.log(workflow.metadata.name, workflow.status.phase);
      });
    });
  });

  it("Test to get pods in litmus namespace", () => {
    cy.request({
      url: apis.getPods("litmus"),
      method: "GET",
      headers: {
        Authorization: `Bearer ${TOKEN}`,
      },
    }).should((response) => {
      const pods = response.body.items;
      pods.map((pod) => {
        cy.log(pod.metadata.name);
      });
    });
  });

  it("Test to get pods by label in litmus namespace", () => {
    cy.request({
      url: apis.getPodByLabel("litmus", "component=litmusportal-frontend"),
      method: "GET",
      headers: {
        Authorization: `Bearer ${TOKEN}`,
      },
    }).should((response) => {
      const pods = response.body.items;
      pods.map((pod) => {
        cy.log(pod.metadata.name);
      });
    });
  });

  it("Test to get chaosresults in litmus namespace", () => {
    cy.request({
      url: apis.getChaosEngines("litmus"),
      method: "GET",
      headers: {
        Authorization: `Bearer ${TOKEN}`,
      },
    }).should((response) => {
      const chaosresults = response.body.items;
      chaosresults.map((chaosresult) => {
        cy.log(chaosresult.metadata.name);
      });
    });
  });

  it("Test to get CronWorkflows in litmus namespace", () => {
    cy.request({
      url: apis.getCronWorkflows("litmus"),
      method: "GET",
      headers: {
        Authorization: `Bearer ${TOKEN}`,
      },
    }).should((response) => {
      const cronworkflows = response.body.items;
      cronworkflows.map((cronworkflow) => {
        cy.log(cronworkflow.metadata.name);
      });
    });
  });
});
