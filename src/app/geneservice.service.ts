/**
 * Created by husainnf on 11/6/2017.
 */
import { Component, OnInit } from '@angular/core';
import { Http, Response } from '@angular/http';

import { Observable } from 'rxjs';
import { Injectable } from '@angular/core';



import { NgForm } from '@angular/forms'
import {GenesComponent} from "./genes/genes.component";


@Injectable()
export class GenesService implements OnInit {

    // can only use *ngIf and *ngFor on Arrays

    public genes: any[] = [];
    private genesComponent: GenesComponent;

    pageTitle: string;
    genesUrl = "http://trace.ncbi.nlm.nih.gov/Traces/sra/";

    // Inject http here
    constructor(private http: Http){

        this.pageTitle = 'Genes from SRA';

        this.genes = [];

        //console.log("Form values are: ");
        //console.log(genesComponent.genesFormValues);

    }



    ngOnInit(){
        // set ids before adding new row
        //this.setIDs();
        //this.getGenes();
    }


    // with Observable
    //getGenes(): Observable<GenesComponent[]> {
        //return this.http.get<GenesComponent[]>(this.genesUrl, {params: {'sp': 'runinfo', 'acc': 'SRR5970434'}})
    //    return this.http.get<GenesComponent[]>(this.genesUrl)
    //}

    // without Observable
    getGenes(): Promise<any> {


        //console.log("Form values in getGenes are: ");
        //console.log(this.genesComponent.getFormValuesJSON);
        if (typeof(Storage) !== "undefined") {
            // Store
            console.log("genesformvalues to pass in are: ")
            console.log(localStorage.getItem("genesformvalues"));
        }

        console.log("genesurl in getGenes is: " + this.genesUrl);

        //return this.http.get<GenesComponent[]>(this.genesUrl, {params: {'sp': 'runinfo', 'acc': 'SRR5970434'}}).toPromise();
        //return this.http.post(this.genesUrl, {params: {'sp': 'runinfo', 'acc': 'SRR5970434'}}).toPromise();
        return this.http.post(this.genesUrl, {params: localStorage.getItem("genesformvalues")}).toPromise();
    };
        //this.http.get(this.genesUrl, {params: {'sp': 'runinfo', 'acc': 'SRR5970434'}});
        //this.http.get(this.genesUrl);



    private currentPriceUrl = 'http://api.coindesk.com/v1/bpi/currentprice.json';


  getPrice(currency: string): Promise<number> {
    return this.http.get(this.currentPriceUrl).toPromise()
      .then(response => response.json().bpi[currency].rate);
  }
}