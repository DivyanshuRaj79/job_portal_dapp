// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0; 

contract MigrantWorkerDapp { 

    address public admin;  // The address of the admin who can add applicants and jobs. 

    enum ApplicantType { underGraduate, Graduate, postGraduate }
 
    struct Applicant { 
        uint id;
        string name; 
        string laborHistory; 
        string skills; 
        bool availability;
        uint256 rating; 
        ApplicantType applicantType;
    } 

    struct Job { 
        uint id;
        string title; 
        string description; 
        uint256 salary; 
        address employer;
        bool isOpen; 
    } 

    Applicant[] public applicants;
    Job[] public jobs;
    mapping(uint256 => mapping(uint256 => bool)) public applications;  // Mapping from job ID to applicant ID to check if applied. 
 
    constructor() { 
        admin = msg.sender; 
    } 

    modifier onlyAdmin() { 
        require(msg.sender == admin, "Only admin can perform this action"); 
        _; 
    } 

     /********************************************************************************************************************
     *
     *  Name        :   addApplicant
     *  Description :   This function is used by the admin to add a new applicant to the Migrant Worker Dapp.
     *                  This function can be called by admin only.
     *  Parameters  :
     *      param  {string} _name : The name of the applicant.
     *      param  {string} _laborHistory : Labor history or work experience of the applicant.
     *      param  {string} _skills : Skills possessed by the applicant.
     *      param  {ApplicantType} _applicantType : Type of the applicant (e.g., underGraduate, Graduate, postGraduate).
     *
     *******************************************************************************************************************/

    function addApplicant(
        string memory _name, 
        string memory _laborHistory, 
        string memory _skills, 
        ApplicantType _applicantType
    ) external onlyAdmin { 
        uint _id = applicants.length;
        applicants.push(Applicant(_id+1, _name, _laborHistory, _skills, true, 0, _applicantType));
    } 

    /********************************************************************************************************************
     *
     *  Name        :   getApplicantDetails
     *  Description :   Get the details of an applicant based on their ID.
     *  Parameters  :
     *      param  {uint} _applicantId : The unique ID of the applicant.
     *  Returns     :
     *      return {uint} id : The unique ID of the applicant.
     *      return {string} name : The name of the applicant.
     *      return {string} laborHistory : Labor history or work experience of the applicant.
     *      return {string} skills : Skills possessed by the applicant.
     *      return {bool} availability : Availability status of the applicant.
     *      return {uint} rating : The rating of the applicant.
     *
     *******************************************************************************************************************/

     function getApplicantDetails(uint _applicantId) public view returns (
        uint id,
        string memory name,
        string memory laborHistory,
        string memory skills,
        bool availability,
        uint rating
    ) {
        require(_applicantId > 0 && _applicantId <= applicants.length, "Invalid applicant ID");
        Applicant memory applicant = applicants[_applicantId-1];
        return (applicant.id, applicant.name, applicant.laborHistory, applicant.skills, applicant.availability, applicant.rating);
    } 

    /********************************************************************************************************************
     *
     *  Name        :   getApplicantType
     *  Description :   Get the type of an applicant based on their ID.
     *  Parameters  :
     *      param  {uint} _applicantId : The unique ID of the applicant.
     *  Returns     :
     *      return {ApplicantType} enumIndex : The enum value representing the type of the applicant.
     *      return {string} applicantType : The human-readable type of the applicant.
     *
     *******************************************************************************************************************/

    function getApplicantType(uint _applicantId) public view returns (
        ApplicantType enumIndex, 
        string memory applicantType
    ) {
        require(_applicantId > 0 && _applicantId <= applicants.length, "Invalid applicant ID");
        if (applicants[_applicantId-1].applicantType == ApplicantType.underGraduate) return (ApplicantType.underGraduate, "underGraduate");
        if (applicants[_applicantId-1].applicantType == ApplicantType.Graduate) return (ApplicantType.Graduate, "Graduate");
        if (applicants[_applicantId-1].applicantType == ApplicantType.postGraduate) return (ApplicantType.postGraduate, "postGraduate");
    }

    /********************************************************************************************************************
     *
     *  Name        :   addJob
     *  Description :   This function is used by the admin to add a new job to the Migrant Worker Dapp.
     *                  This function can be called by admin only.
     *  Parameters  :
     *      param  {string} _title : The title or name of the job.
     *      param  {string} _description : Description of the job.
     *      param  {uint256} _salary : The salary offered for the job.
     *
     *******************************************************************************************************************/

    function addJob(  
        string memory _title, 
        string memory _description, 
        uint256 _salary 
    ) external onlyAdmin { 
        uint _id = jobs.length;
        jobs.push(Job(_id+1, _title, _description, _salary, msg.sender, true));
    } 

    /********************************************************************************************************************
     *
     *  Name        :   getJobDetails
     *  Description :   Get the details of a job based on its ID.
     *  Parameters  :
     *      param  {uint} _jobId : The unique ID of the job.
     *  Returns     :
     *      return {uint} id : The unique ID of the job.
     *      return {string} title : The title or name of the job.
     *      return {string} description : Description of the job.
     *      return {uint256} salary : The salary offered for the job.
     *      return {address} employer : The Ethereum address of the job's employer.
     *      return {bool} isOpen : Job open status.
     *
     *******************************************************************************************************************/ 

    function getJobDetails(uint _jobId) public view returns (
        uint id, 
        string memory title,
        string memory description, 
        uint256 salary,
        address employer,
        bool isOpen
    ) {
        require(_jobId > 0 && _jobId <= jobs.length, "Invalid applicant ID");
        Job memory job = jobs[_jobId-1];
        return (job.id, job.title, job.description, job.salary, job.employer, job.isOpen);
    }

    /********************************************************************************************************************
     *
     *  Name        :   applyForJob
     *  Description :   Allow an applicant to apply for a job.
     *  Parameters  :
     *      param  {uint256} _applicantId : The unique ID of the applicant.
     *      param  {uint256} _jobId : The unique ID of the job.
     *  Conditions  :
     *      - The applicant must be available to apply for the job.
     *      - The job must be open for applications.
     *
     *******************************************************************************************************************/

    function applyForJob(uint256 _applicantId, uint256 _jobId) external { 
        require(applicants[_applicantId-1].availability, "Applicant not available"); 
        require(jobs[_jobId-1].isOpen, "Job not open"); 
        applications[_jobId][_applicantId] = true; 
    } 

    /********************************************************************************************************************
     *
     *  Name        :   provideRating
     *  Description :   Provide a rating to an applicant.
     *  Parameters  :
     *      param  {uint256} _applicantId : The unique ID of the applicant.
     *      param  {uint256} _rating : The rating to be provided (should be between 1 and 5).
     *  Conditions  :
     *      - The applicant must be available to receive a rating.
     *      - The rating must be within the valid range (1 to 5).
     *
     *******************************************************************************************************************/

    function provideRating(uint256 _applicantId, uint256 _rating) external onlyAdmin { 
        require(applicants[_applicantId-1].availability, "Applicant not available"); 
        require(_rating >= 1 && _rating <= 5, "Invalid rating"); 
        applicants[_applicantId-1].rating = _rating; 
    } 

    /********************************************************************************************************************
     *
     *  Name        :   getApplicantRating
     *  Description :   Get the rating of an applicant based on their ID.
     *  Parameters  :
     *      param  {uint256} _applicantId : The unique ID of the applicant.
     *  Returns     :
     *      return {uint256} : The rating of the applicant.
     *
     *******************************************************************************************************************/

    function getApplicantRating(uint256 _applicantId) external view returns (uint256) { 
        return applicants[_applicantId-1].rating; 
    } 

} 