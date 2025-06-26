from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
import os
import logging
import requests

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "dev-secret-key-change-in-production-INSECURE")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

GET_PRODUCTS_ENDPOINT = os.getenv("GET_PRODUCTS_URL")
ADD_PRODUCT_ENDPOINT = os.getenv("ADD_PRODUCT_URL")
BUY_PRODUCT_ENDPOINT = os.getenv("BUY_PRODUCT_URL")


def fetch_products():
    """Retrieve product list from the lambda."""
    if not GET_PRODUCTS_ENDPOINT:
        logger.warning("GET_PRODUCTS_URL not configured")
        return []

    try:
        response = requests.get(GET_PRODUCTS_ENDPOINT, timeout=10)
        if response.status_code == 200:
            return response.json()
        logger.error("Lambda GET_PRODUCTS returned %s", response.status_code)
    except Exception as exc:
        logger.error("Error contacting GET_PRODUCTS lambda: %s", exc)
    return []


@app.route('/')
def index():
    products = fetch_products()
    return render_template('index.html', products=products)


@app.route('/products')
def list_products():
    if not GET_PRODUCTS_ENDPOINT:
        return jsonify({'error': 'Configuration missing'}), 500
    try:
        response = requests.get(GET_PRODUCTS_ENDPOINT, timeout=10)
        return (jsonify(response.json()), 200) if response.status_code == 200 else (jsonify({'error': 'Unable to obtain products'}), 500)
    except Exception as exc:
        logger.error("/products failed: %s", exc)
        return jsonify({'error': 'Server error'}), 500


@app.route('/buy/<int:product_id>', methods=['POST'])
def buy_product(product_id):
    if not BUY_PRODUCT_ENDPOINT:
        flash('Buy function unavailable', 'error')
        return redirect(url_for('index'))

    try:
        response = requests.post(BUY_PRODUCT_ENDPOINT, json={'product_id': product_id}, timeout=10)
        if response.status_code == 200:
            result = response.json()
            if 'error' in result:
                flash(f"Error: {result['error']}", 'error')
            else:
                flash('Product purchased successfully!', 'success')
        else:
            flash('Error processing purchase', 'error')
    except Exception as exc:
        logger.error("buy_product failed: %s", exc)
        flash('Internal error', 'error')
    return redirect(url_for('index'))


@app.route('/add-product', methods=['GET', 'POST'])
def add_product():
    if request.method == 'GET':
        return render_template('add_product.html')

    name = request.form.get('name')
    price = request.form.get('price')
    description = request.form.get('description', '')

    if not name or not price:
        flash('Name and price are required', 'error')
        return redirect(url_for('add_product'))

    try:
        price_val = float(price)
        if price_val <= 0:
            flash('Price must be greater than 0', 'error')
            return redirect(url_for('add_product'))
    except ValueError:
        flash('Invalid price', 'error')
        return redirect(url_for('add_product'))

    if not ADD_PRODUCT_ENDPOINT:
        flash('Add product function unavailable', 'error')
        return redirect(url_for('add_product'))

    payload = {'name': name, 'price': price_val, 'description': description}
    try:
        response = requests.post(ADD_PRODUCT_ENDPOINT, json=payload, timeout=10)
        if response.status_code in (200, 201):
            result = response.json()
            if 'error' in result:
                flash(f"Error: {result['error']}", 'error')
            else:
                flash('Product added!', 'success')
                return redirect(url_for('index'))
        else:
            flash('Error adding product', 'error')
    except Exception as exc:
        logger.error("add_product failed: %s", exc)
        flash('Internal error adding product', 'error')
    return redirect(url_for('add_product'))


@app.route('/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'lambda_urls_configured': {
            'get_products': bool(GET_PRODUCTS_ENDPOINT),
            'add_product': bool(ADD_PRODUCT_ENDPOINT),
            'buy_product': bool(BUY_PRODUCT_ENDPOINT)
        }
    })


@app.errorhandler(404)
def not_found(error):
    return render_template('error.html', error='Not Found'), 404


@app.errorhandler(500)
def internal_error(error):
    return render_template('error.html', error='Server Error'), 500


if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)