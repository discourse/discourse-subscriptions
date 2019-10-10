export default function(helpers) {
  const { response } = helpers;

  this.get("/patrons", () => response({ email: "hello@example.com" }));

  this.get("/groups/:plan", id => {
    return response({ full_name: "Saboo", bio_cooked: "This is the plan" });
  });
}
